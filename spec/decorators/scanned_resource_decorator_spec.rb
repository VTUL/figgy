# frozen_string_literal: true
require 'rails_helper'

RSpec.describe ScannedResourceDecorator do
  subject(:decorator) { described_class.new(resource) }
  let(:resource) { FactoryBot.build(:scanned_resource) }
  describe "#rendered_rights_statement" do
    it "returns an HTML rights statement" do
      term = ControlledVocabulary.for(:rights_statement).find(resource.rights_statement.first)
      expect(decorator.rendered_rights_statement.length).to eq 1
      expect(decorator.rendered_rights_statement.first).to include term.definition
      expect(decorator.rendered_rights_statement.first).to include I18n.t("valhalla.works.show.attributes.rights_statement.boilerplate")
      expect(decorator.rendered_rights_statement.first).to include '<a href="http://rightsstatements.org/vocab/NKC/1.0/">No Known Copyright</a>'
    end
  end
  describe '#created' do
    let(:resource) do
      FactoryBot.build(:scanned_resource,
                       title: 'test title',
                       created: '01/01/1970',
                       imported_metadata: [{
                         creator: 'test creator'
                       }])
    end
    it 'exposes a formatted string for the created date' do
      expect(decorator.created).to eq ["January 1, 1970"]
    end
  end
  describe "#imported_created" do
    let(:resource) do
      FactoryBot.build(:scanned_resource,
                       title: 'test title',
                       created: '01/01/1970',
                       imported_metadata: [{
                         creator: 'test creator',
                         created: Date.parse("01/01/1970")
                       }])
    end
    it 'exposes a formatted string for the created date' do
      expect(decorator.imported_created).to eq ["January 1, 1970"]
    end
  end
  context 'with imported metadata' do
    let(:resource) do
      FactoryBot.build(:scanned_resource,
                       title: 'test title',
                       author: 'test author',
                       imported_metadata: [{
                         creator: 'test creator',
                         subject: 'test subject',
                         language: 'eng'
                       }])
    end
    describe "#iiif_manifest_attributes" do
      it "returns attributes merged with the imported metadata for the IIIF Manifest" do
        expect(decorator.iiif_manifest_attributes).to include title: ['test title']
        expect(decorator.iiif_manifest_attributes).to include author: ['test author']
        expect(decorator.iiif_manifest_attributes).to include creator: ['test creator']
        expect(decorator.iiif_manifest_attributes).to include subject: ['test subject']
      end
    end
    describe "#display_imported_language" do
      it "maps keys to english strings" do
        expect(decorator.display_imported_language).to eq ["English"]
      end
    end
    describe "raw imported metadata" do
      it "is not displayed" do
        expect(decorator.display_attributes.keys).not_to include :source_metadata
      end
    end
  end
  context 'within a collection' do
    let(:collection) do
      adapter = Valkyrie::MetadataAdapter.find(:indexing_persister)
      res = FactoryBot.build(:collection)
      adapter.persister.save(resource: res)
    end
    let(:resource) { FactoryBot.create_for_repository(:scanned_resource, member_of_collection_ids: [collection.id]) }
    it 'retrieves the title of parents' do
      expect(resource.decorate.member_of_collections).not_to be_empty
      expect(resource.decorate.member_of_collections.first).to be_a CollectionDecorator
      expect(resource.decorate.member_of_collections.first.title).to eq 'Title'
    end
  end
end
