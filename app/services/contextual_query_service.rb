# frozen_string_literal: true
class ContextualQueryService
  attr_reader :resource, :query_service
  def initialize(resource:, query_service:)
    @resource = resource
    @query_service = query_service
  end

  def members
    binding.pry if resource.respond_to?(:member_ids) && resource.member_ids.nil?
    @members ||= query_service.find_members(resource: resource).to_a
  end

  def decorated_members
    @decorated_members ||= members.map(&:decorate)
  end

  def volumes
    @volumes ||= members.select { |r| r.is_a?(ScannedResource) }.to_a
  end

  def decorated_volumes
    @decorated_volumes ||= volumes.map(&:decorate)
  end

  def file_sets
    @file_sets ||= members.select { |r| r.is_a?(FileSet) }.to_a
  end

  def decorated_file_sets
    @decorated_file_sets ||= file_sets.map(&:decorate)
  end
end
