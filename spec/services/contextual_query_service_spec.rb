# frozen_string_literal: true
require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe ContextualQueryService do
  subject(:contextual_query_service) { described_class.new(resource: resource, query_service: query_service) }
  let(:child_query_service) { described_class.new(resource: child, query_service: query_service) }
  let(:query_service) { Valkyrie::MetadataAdapter.find(:indexing_persister).query_service }
  let(:resource) { FactoryBot.create_for_repository(:scanned_resource, member_ids: child.id, member_of_collection_ids: collection.id) }
  let(:child) { FactoryBot.create_for_repository(:scanned_resource, files: [file]) }
  let(:collection) { FactoryBot.create_for_repository(:collection) }
  let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }

  describe ".members" do
    it "returns all the members" do
      expect(contextual_query_service.members.map(&:id)).to eq [child.id]
      expect(contextual_query_service.members.first).to be_a ScannedResource
    end
    it "can decorate members" do
      expect(contextual_query_service.decorated_members.first).to be_a ScannedResourceDecorator
    end
  end

  describe ".volumes" do
    it "returns only children which are ScannedResources" do
      expect(contextual_query_service.volumes.map(&:id)).to eq [child.id]
      expect(contextual_query_service.volumes.first).to be_a ScannedResource
      expect(child_query_service.volumes).to eq []
    end
    it "can decorate volumes" do
      expect(contextual_query_service.decorated_volumes.first).to be_a ScannedResourceDecorator
    end
  end

  describe ".parents" do
    it "returns parents" do
      expect(contextual_query_service.parents).to eq []
      expect(child_query_service.parents.map(&:id)).to eq [resource.id]
    end
    it "can decorate parents" do
      expect(contextual_query_service.decorated_parents).to eq []
      expect(child_query_service.decorated_parents.first).to be_a ScannedResourceDecorator
    end
  end

  describe ".file_sets" do
    it "returns only children which are file_sets" do
      expect(contextual_query_service.file_sets).to eq []
      expect(child_query_service.file_sets.length).to eq 1
    end
    it "can decorate file sets" do
      expect(child_query_service.decorated_file_sets.first).to be_a FileSetDecorator
    end
  end

  describe ".member_of_collections" do
    it "returns all collections an object is a member of" do
      expect(contextual_query_service.member_of_collections.map(&:id)).to eq [collection.id]
    end
    it "can decorate collections" do
      expect(contextual_query_service.decorated_member_of_collections.first).to be_a CollectionDecorator
    end
  end
end
