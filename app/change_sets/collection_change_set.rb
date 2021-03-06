# frozen_string_literal: true
class CollectionChangeSet < Valkyrie::ChangeSet
  delegate :human_readable_type, to: :model
  property :title, multiple: false, required: true
  property :slug, multiple: false, required: true
  property :description, multiple: false, required: false
  property :visibility, multiple: false, required: false
  validates :title, :slug, presence: true

  def primary_terms
    [:title, :slug, :description]
  end
end
