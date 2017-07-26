# frozen_string_literal: true
module Valhalla
  class ContextualPath
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes
    attr_reader :child, :parent_id
    def initialize(child:, parent_id: nil)
      @child = child
      @parent_id = parent_id
    end

    def show
      if parent_id
        polymorphic_path([:parent, :solr_document], parent_id: parent_id, id: "id-#{child.id}")
      else
        polymorphic_path([:solr_document], id: "id-#{child.id}")
      end
    end

    def to_resource
      nil
    end
  end
end
