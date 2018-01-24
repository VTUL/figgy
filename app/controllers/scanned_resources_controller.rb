# frozen_string_literal: true
class ScannedResourcesController < BaseResourceController
  self.change_set_class = DynamicChangeSet
  self.resource_class = ScannedResource
  self.change_set_persister = ::PlumChangeSetPersister.new(
    metadata_adapter: Valkyrie::MetadataAdapter.find(:indexing_persister),
    storage_adapter: Valkyrie.config.storage_adapter
  )

  def show
    @resource = begin
                  find_resource(params[:id])
                rescue Valkyrie::Persistence::ObjectNotFoundError
                  find_resource_by_local_identifier(params[:id])
                end
    redirect_to solr_document_path(id: @resource.id.to_s)
  end

  def find_resource_by_local_identifier(id)
    query_service.custom_queries.find_by_local_identifier(local_identifier: id).first
  end

  def after_create_success(obj, change_set)
    super
    handle_save_and_ingest(obj)
  end

  def handle_save_and_ingest(obj)
    return unless params[:commit] == "Save and Ingest"
    locator = IngestFolderLocator.new(id: params[:scanned_resource][:source_metadata_identifier])
    IngestFolderJob.perform_later(directory: locator.folder_pathname.to_s, property: "id", id: obj.id.to_s)
  end

  # manifest thing
  def structure
    @change_set = change_set_class.new(find_resource(params[:id])).prepopulate!
    @logical_order = (Array(@change_set.logical_structure).first || Structure.new).decorate
    @logical_order = WithProxyForObject.new(@logical_order, query_service.find_members(resource: @change_set.id).to_a)
    authorize! :structure, @change_set.resource
  end

  def manifest
    @resource = find_resource(params[:id])
    authorize! :manifest, @resource
    respond_to do |f|
      f.json do
        render json: ManifestBuilder.new(@resource).build
      end
    end
  end

  def pdf
    change_set = change_set_class.new(find_resource(params[:id])).prepopulate!
    authorize! :pdf, change_set.resource
    pdf_file = PDFGenerator.new(resource: change_set.resource, storage_adapter: Valkyrie::StorageAdapter.find(:derivatives)).render
    change_set_persister.buffer_into_index do |buffered_changeset_persister|
      change_set.validate(file_metadata: [pdf_file])
      change_set.sync
      buffered_changeset_persister.save(change_set: change_set)
    end
    redirect_to valhalla.download_path(resource_id: change_set.id, id: pdf_file.id)
  end

  def save_and_ingest
    authorize! :create, resource_class
    respond_to do |f|
      f.json do
        render json: save_and_ingest_response
      end
    end
  end

  def save_and_ingest_response
    locator = IngestFolderLocator.new(id: params[:id])
    {
      exists: locator.exists?,
      location: locator.location,
      file_count: locator.file_count,
      volume_count: locator.volume_count
    }
  end

  class IngestFolderLocator
    attr_reader :id
    def initialize(id:)
      @id = id
    end

    def root_path
      Pathname.new(BrowseEverything.config["file_system"][:home]).join("studio_new")
    end

    def exists?
      folder_location.present?
    end

    def location
      return unless exists?
      folder_pathname.relative_path_from(root_path)
    end

    def file_count
      return unless exists?
      Dir.glob(folder_pathname.join("**")).select do |file|
        File.file?(file)
      end.count
    end

    def volume_count
      return unless exists?
      Dir.glob(folder_pathname.join("**")).select do |file|
        File.directory?(file)
      end.count
    end

    def folder_pathname
      @folder_pathname ||= Pathname.new(folder_location)
    end

    private

      def folder_location
        @folder_location ||= Dir.glob(root_path.join("**/#{id}")).first
      end
  end
end
