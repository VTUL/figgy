# frozen_string_literal: false
class ScannedMapDecorator < Valkyrie::ResourceDecorator
  display(Schema::Geo.attributes)
  display(
    [
      :rendered_coverage,
      :member_of_collections,
      :relation,
      :rendered_links
    ]
  )
  suppress(
    [
      :thumbnail_id,
      :coverage,
      :cartographic_projection,
      :source_jsonld,
      :sort_title
    ]
  )
  iiif_manifest_display(displayed_attributes)
  iiif_manifest_suppress(Schema::IIIF.attributes)
  iiif_manifest_suppress(
    [
      :visibility,
      :internal_resource,
      :rights_statement,
      :rendered_rights_statement,
      :thumbnail_id
    ]
  )

  delegate(*Schema::Common.attributes, to: :primary_imported_metadata, prefix: :imported)

  def members
    @members ||= query_service.find_members(resource: model).to_a
  end

  def scanned_map_members
    @scanned_maps ||= members.select { |r| r.is_a?(ScannedMap) }.map(&:decorate).to_a
  end

  def geo_members
    members.select do |member|
      next unless member.respond_to?(:mime_type)
      ControlledVocabulary.for(:geo_image_format).include?(member.mime_type.first)
    end
  end

  def geo_metadata_members
    members.select do |member|
      next unless member.respond_to?(:mime_type)
      ControlledVocabulary.for(:geo_metadata_format).include?(member.mime_type.first)
    end
  end

  def rendered_rights_statement
    rights_statement.map do |rights_statement|
      term = ControlledVocabulary.for(:rights_statement).find(rights_statement)
      next unless term
      h.link_to(term.label, term.value) +
        h.content_tag("br") +
        h.content_tag("p") do
          term.definition.html_safe
        end +
        h.content_tag("p") do
          I18n.t("valhalla.works.show.attributes.rights_statement.boilerplate").html_safe
        end
    end
  end

  def rendered_coverage
    h.bbox_display(coverage)
  end

  def rendered_links
    return unless references
    refs = JSON.parse(references.first)
    refs.delete('iiif_manifest_paths')
    refs.map do |url, _label|
      h.link_to(url, url)
    end
  end

  def manageable_structure?
    true
  end

  def attachable_objects
    [ScannedMap]
  end

  # Access the resource attributes imported from an external service
  # @return [Hash] a Hash of all of the resource attributes
  def imported_attributes
    @imported_attributes ||= ImportedAttributes.new(subject: self, keys: self.class.displayed_attributes).to_h
  end

  # Display the resource attributes
  # @return [Hash] a Hash of all of the resource attributes
  def display_attributes
    super.reject { |k, v| imported_attributes.fetch(k, nil) == v }
  end

  # Access the resources attributes exposed for the IIIF Manifest metadata
  # @return [Hash] a Hash of all of the resource attributes
  def iiif_manifest_attributes
    super.merge imported_attributes
  end

  def language
    (super || []).map do |language|
      ControlledVocabulary.for(:language).find(language).label
    end
  end

  def imported_attribute(attribute_key)
    return primary_imported_metadata.send(attribute_key) if primary_imported_metadata.try(attribute_key)
    Array.wrap(primary_imported_metadata.attributes.fetch(attribute_key, []))
  end

  def imported_language
    imported_attribute(:language).map do |language|
      ControlledVocabulary.for(:language).find(language).label
    end
  end
  alias display_imported_language imported_language
end
