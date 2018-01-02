# frozen_string_literal: true
class CollectionIndexer
  attr_reader :resource
  def initialize(resource:)
    @resource = resource
  end

  def to_solr
    return {} unless collection_titles.any?
    {
      "member_of_collection_titles_ssim" => collection_titles
    }
  end

  def collection_titles
    @collection_titles ||=
      ephemera_collection_titles.any? ? ephemera_collection_titles : collections.map(&:title).to_a
  end

  def decorated_resource
    @decorated_resource ||= resource.decorate
  end

  def ephemera_collection_titles
    return [] unless resource.is_a?(EphemeraFolder) && decorated_resource.ephemera_box
    decorated_resource.ephemera_box.decorated_member_of_collections.map(&:title)
  end

  def collections
    @collections ||= resource.decorate.decorated_member_of_collections
  end
end
