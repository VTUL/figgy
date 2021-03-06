# frozen_string_literal: true
class FindMissingThumbnailResources
  # Access the list of methods exposed for the query
  # @return [Array<Symbol>] query method signatures
  def self.queries
    [:find_missing_thumbnail_resources]
  end

  attr_reader :query_service
  delegate :connection, to: :query_service
  delegate :resource_factory, to: :query_service
  # Constructor
  # @param query_service [Valkyrie::Persistence::Solr::QueryService] the query service for Solr
  def initialize(query_service:)
    @query_service = query_service
  end

  # Method for finding all resources missing thumbnail IDs
  # @param model [Valhalla::Resource] the model for the resources
  def find_missing_thumbnail_resources(model: ScannedResource)
    run(model)
  end

  private

    # The query for Solr
    # @param model [Valhalla::Resource] the model for the resources
    def query(model)
      "#{Valkyrie::Persistence::Solr::Queries::MODEL}:#{model} AND -thumbnail_id_ssim:[* TO *]"
    end

    # Iterate through the results of the query
    # @param model [Valhalla::Resource] the model for the resources
    # @yield [Valhalla::Resource] a resource missing a thumbnail ID
    def each(model)
      docs = Valkyrie::Persistence::Solr::Queries::DefaultPaginator.new
      while docs.has_next?
        docs = connection.paginate(docs.next_page, docs.per_page, "select", params: { q: query(model) })["response"]["docs"]
        docs.each do |doc|
          yield resource_factory.to_resource(object: doc)
        end
      end
    end

    # Execute the query
    # @param model [Valhalla::Resource] the model for the resources
    def run(model)
      enum_for(:each, model)
    end
end
