# frozen_string_literal: true
FactoryGirl.define do
  factory :ephemera_folder do
    to_create do |instance|
      Valkyrie.config.metadata_adapter.persister.save(resource: instance)
    end
  end
end
