# frozen_string_literal: true
# Templates are used to apply default metadata to multiple ephemera objects
class Template < Valhalla::Resource
  include Valkyrie::Resource::AccessControls
  attribute :id, Valkyrie::Types::ID.optional
  attribute :title
  attribute :parent_id
  attribute :nested_properties, Valkyrie::Types::Array.member(Valkyrie::Types::Anything.optional).optional
  attribute :model_class
end
