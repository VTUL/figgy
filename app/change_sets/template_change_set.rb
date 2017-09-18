# frozen_string_literal: true
class TemplateChangeSet < Valhalla::ChangeSet
  self.fields = [:title]
  property :title, required: true, multiple: false
  property :model_class, multiple: false, required: true
  property :nested_properties, type: Types::Strict::Array.member(Types::Strict::Hash), default: [{}]
  property :child_change_set_attributes, virtual: true
  property :parent_id, multiple: false, type: Valkyrie::Types::ID.optional
  validates :title, presence: true

  def child_change_set_attributes=(attributes)
    self.nested_properties = [attributes.to_unsafe_h.merge(internal_resource: model_class)]
    @child_change_set = nil
    @child_record = nil
    true
  end

  def child_change_set
    @child_change_set ||= TemplateChangeSetDecorator.new(DynamicChangeSet.new(child_record)).tap(&:prepopulate!)
  end

  def child_record
    @child_record ||= model_class.constantize.new(nested_properties.first.to_h || {})
  end

  class TemplateChangeSetDecorator < SimpleDelegator
    def required?(_property)
      false
    end

    delegate :class, to: :__getobj__
  end
end
