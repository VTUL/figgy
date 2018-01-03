# frozen_string_literal: true
class FileSetDecorator < Valkyrie::ResourceDecorator
  display(
    [
      :height,
      :width,
      :mime_type,
      :size,
      :md5,
      :sha1,
      :sha256
    ]
  )

  def manageable_files?
    false
  end

  def parent
    decorated_parents.first
  end

  def collection_slugs
    @collection_slugs ||= parent.try(:collection_slugs)
  end
end
