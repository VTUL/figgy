# frozen_string_literal: true
class SourceMetadataIdentifierValidator < ActiveModel::Validator
  def validate(record)
    return unless record.apply_remote_metadata?
    return if RemoteRecord.retrieve(Array(record.source_metadata_identifier).first).success?
    record.errors.add(:source_metadata_identifier, "Error retrieving metadata")
  end
end
