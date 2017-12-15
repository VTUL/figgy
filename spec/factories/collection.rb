# frozen_string_literal: true
FactoryBot.define do
  factory :collection do
    title 'Title'
    slug 'test'
    visibility 'open'
    read_groups 'public'
    to_create do |instance|
      Valkyrie.config.metadata_adapter.persister.save(resource: instance)
    end
    factory :private_collection do
      visibility 'private'
    end
  end
end
