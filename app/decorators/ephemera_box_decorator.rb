# frozen_string_literal: true
class EphemeraBoxDecorator < Valkyrie::ResourceDecorator
  display(
    [
      :barcode,
      :box_number,
      :shipped_date,
      :tracking_number,
      :drive_barcode,
      :visibility,
      :member_of_collections
    ]
  )

  def title
    "Box #{box_number.first}"
  end

  def ephemera_projects
    decorated_parents
  end

  def collection_slugs
    @collection_slugs ||= ephemera_projects.map(&:slug)
  end

  def ephemera_project
    @ephemera_project ||= ephemera_projects.first || NullProject.new
  end

  class NullProject
    def title; end

    def header
      nil
    end

    def templates
      []
    end

    def nil?
      true
    end
  end

  def manageable_files?
    false
  end

  def manageable_structure?
    false
  end

  def attachable_objects
    [EphemeraFolder]
  end

  def rendered_state
    ControlledVocabulary.for(:state_box_workflow).badge(state)
  end

  def state
    super.first
  end

  def drive_barcode
    super.first
  end

  def barcode
    super.first
  end
end
