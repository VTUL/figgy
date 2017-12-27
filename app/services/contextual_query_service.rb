class ContextualQueryService
  attr_reader :resource, :query_service
  def initialize(resource:, query_service:)
    @resource = resource
    @query_service = query_service
  end

  def members
    @members ||= query_service.find_members(resource: resource).to_a
  end

  def volumes
    @volumes ||= members.select { |r| r.is_a?(ScannedResource) }.to_a
  end

  def file_sets
    @file_sets ||= members.select { |r| r.is_a?(FileSet) }.to_a
  end
end
