# frozen_string_literal: true
class Valkyrie::ResourceDecorator < ApplicationDecorator
  self.suppressed_attributes = [
    :description,
    :rights_statement,
    :holding_location,
    :title,
    :depositor,
    :source_metadata_identifier,
    :source_metadata,
    :nav_date,
    :pdf_type,
    :ocr_language,
    :keyword,
    :source_jsonld,
    :sort_title
  ]
  self.display_attributes = [:internal_resource, :created_at, :updated_at]

  def created_at
    output = super
    return if output.blank?
    output.strftime("%D %r %Z")
  end

  def updated_at
    output = super
    return if output.blank?
    output.strftime("%D %r %Z")
  end

  def visibility
    Array(super).map do |visibility|
      h.visibility_badge(visibility)
    end
  end

  def header
    Array(title).to_sentence
  end

  def manageable_files?
    true
  end

  def manageable_structure?
    false
  end

  def attachable_objects
    []
  end
end
