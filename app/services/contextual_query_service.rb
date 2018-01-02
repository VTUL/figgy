# frozen_string_literal: true
class ContextualQueryService
  attr_reader :resource, :query_service
  # Method to shorten creating methods like `decorated_members` which return the
  # array of members as decorated objects.
  def self.decorates_methods(*methods)
    methods.each do |method|
      define_method :"decorated_#{method}" do
        output = instance_variable_get(:"@decorated_#{method}") ||
                 __send__(method).map(&:decorate)
        instance_variable_set(:"@decorated_#{method}", output)
      end
    end
  end

  decorates_methods :members, :volumes, :file_sets, :parents, :member_of_collections, :collection_members, :ephemera_folders, :ephemera_projects

  def initialize(resource:, query_service:)
    @resource = resource
    @query_service = query_service
  end

  def members
    return [] if resource.try(:member_ids).blank?
    @members ||= query_service.find_members(resource: resource).to_a
  end

  def volumes
    @volumes ||= members_of_type(type: ScannedResource)
  end

  def file_sets
    @file_sets ||= members_of_type(type: FileSet)
  end

  def ephemera_folders
    @ephemera_folders ||= members_of_type(type: EphemeraFolder)
  end

  def members_of_type(type:)
    members.select { |r| r.is_a?(type) }.to_a
  end

  def parents
    @parents ||= query_service.find_parents(resource: resource).to_a
  end

  def ephemera_projects
    @ephemera_projects ||= parents.select { |r| r.is_a?(EphemeraProject) }.to_a
  end

  def member_of_collections
    return [] unless resource.respond_to?(:member_of_collection_ids)
    @member_of_collections ||=
      query_service.find_references_by(resource: resource, property: :member_of_collection_ids).to_a
  end

  def collection_members
    @collection_members ||= query_service.find_inverse_references_by(resource: resource, property: :member_of_collection_ids).to_a
  end
end
