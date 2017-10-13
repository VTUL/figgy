# frozen_string_literal: true

# these methods created for use in rake tasks and db/seeds.rb
require 'faker'

class DataSeeder
  attr_accessor :logger

  def initialize(logger = Logger.new(STDOUT))
    raise("DataSeeder is not for use in production!") if Rails.env == 'production'
    @logger = logger
  end

  def generate_dev_data(many_files:, many_members:)
    generate_resource_with_many_files(n: many_files)
    generate_resource_with_many_members(n: many_members)
    generate_scanned_map
    object_count_report
  end

  def wipe_metadata!
    Valkyrie::MetadataAdapter.adapters.each_value { |adapter| adapter.persister.wipe! }
  end

  def wipe_files!
    [Figgy.config['derivative_path'], Figgy.config['repository_path']].each do |dir_path|
      Pathname.new(dir_path).children.each(&:rmtree)
    end
  end

  def generate_resource_with_many_files(n:)
    sr = ScannedResource.new(attributes_hash.merge(title: "Multi-file resource"))
    sr = Valkyrie::MetadataAdapter.find(:indexing_persister).persister.save(resource: sr)
    n.times { add_file(resource: sr) }
    logger.info "Created scanned resource #{sr.id}: #{sr.title} with #{n} files"
  end

  def generate_resource_with_many_members(n:)
    parent = generate_scanned_resource(title: "Parent resource with many members")
    n.times do
      add_child_resource(child: generate_scanned_resource, parent_id: parent.id)
    end
  end

  def generate_scanned_resource(attrs = {})
    sr = ScannedResource.new(attributes_hash.merge(attrs))
    sr = Valkyrie::MetadataAdapter.find(:indexing_persister).persister.save(resource: sr)
    add_file(resource: sr)
    logger.info "Created scanned resource #{sr.id}: #{sr.title}"
    sr
  end

  def generate_scanned_map
    sm = ScannedMap.new(attributes_hash)
    sm = Valkyrie::MetadataAdapter.find(:indexing_persister).persister.save(resource: sm)
    add_file(resource: sm)
    logger.info "Created scanned map #{sm.id}: #{sm.title}"
  end

  private

    def attributes_hash
      {
        title: Faker::Space.star,
        description: Faker::Matz.quote,
        rights_statement: rights_statements[rand(rights_statements.count)].value,
        files: [],
        read_groups: 'public',
        state: 'complete',
        visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
        import_metadata: false
      }
    end

    def rights_statements
      ControlledVocabulary.for(:rights_statement).all
    end

    def add_child_resource(child:, parent_id:)
      change_set = DynamicChangeSet.new(child)
      change_set.append_id = parent_id
      change_set.prepopulate!
      ::PlumChangeSetPersister.new(
        metadata_adapter: Valkyrie::MetadataAdapter.find(:indexing_persister),
        storage_adapter: Valkyrie.config.storage_adapter
      ).save(change_set: change_set)
    end

    def add_file(resource:)
      change_set = DynamicChangeSet.new(resource)
      change_set.files = [IngestableFile.new(file_path: Rails.root.join('spec', 'fixtures', 'files', 'example.tif'), mime_type: "image/tiff", original_filename: "example.tif")]
      change_set.prepopulate!
      ::PlumChangeSetPersister.new(
        metadata_adapter: Valkyrie::MetadataAdapter.find(:indexing_persister),
        storage_adapter: Valkyrie.config.storage_adapter
      ).save(change_set: change_set)
    end

    def object_count_report
      report = []
      db_count = Valkyrie::MetadataAdapter.find(:indexing_persister).query_service.find_all.count
      report << "#{db_count} total objects in metadata store"
      solr_count = Valkyrie::MetadataAdapter.find(:index_solr).query_service.find_all.count
      report << "#{solr_count} total objects in index"
      report.each do |line|
        logger.info line
      end
    end
end