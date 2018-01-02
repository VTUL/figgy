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
  let(:collection_query_service) { described_class.new(resource: collection, query_service: query_service) }
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

  describe ".collection_members" do
    it "returns all objects that are a member of the collection" do
      resource
      expect(collection_query_service.collection_members.map(&:id)).to eq [resource.id]
    end
    it "can decorate them" do
      resource
      expect(collection_query_service.decorated_collection_members.first).to be_a ScannedResourceDecorator
    end
  end

  describe ".ephemera_folders" do
    let(:resource) { FactoryBot.create_for_repository(:ephemera_box, member_ids: child.id, member_of_collection_ids: collection.id) }
    let(:child) { FactoryBot.create_for_repository(:ephemera_folder) }
    it "returns all ephemera folders" do
      expect(contextual_query_service.ephemera_folders.map(&:id)).to eq [child.id]
    end
    it "can decorate folders" do
      expect(contextual_query_service.decorated_ephemera_folders.first).to be_a EphemeraFolderDecorator
    end
  end

  describe ".ephemera_projects" do
    let(:resource) { FactoryBot.create_for_repository(:ephemera_project, member_ids: child.id) }
    let(:child) { FactoryBot.create_for_repository(:ephemera_box) }
    it "returns all projects" do
      resource
      expect(child_query_service.ephemera_projects.map(&:id)).to eq [resource.id]
    end
    it "can decorate ephemera_projects" do
      resource
      expect(child_query_service.decorated_ephemera_projects.first).to be_a EphemeraProjectDecorator
    end
  end
end
