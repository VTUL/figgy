# frozen_string_literal: true
require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe ScannedMapsController do
  let(:user) { nil }
  let(:adapter) { Valkyrie::MetadataAdapter.find(:indexing_persister) }
  let(:persister) { adapter.persister }
  let(:query_service) { adapter.query_service }
  before do
    sign_in user if user
  end

  describe "new" do
    it_behaves_like "an access controlled new request"

    context "when not logged in but an auth token is given" do
      it "renders the full manifest" do
        resource = FactoryGirl.create_for_repository(:complete_campus_only_scanned_map)
        authorization_token = AuthToken.create!(group: ["admin"], label: "Administration Token")
        get :manifest, params: { id: resource.id, format: :json, auth_token: authorization_token.token }

        expect(response).to be_success
        expect(response.body).not_to eq "{}"
      end
    end
    context "when they have permission" do
      let(:user) { FactoryGirl.create(:admin) }
      render_views
      it "has a form for creating map images" do
        collection = FactoryGirl.create_for_repository(:collection)
        parent = FactoryGirl.create_for_repository(:scanned_map)

        get :new, params: { parent_id: parent.id.to_s }
        expect(response.body).to have_field "Title"
        expect(response.body).to have_field "Source Metadata ID"
        expect(response.body).to have_field "scanned_map[refresh_remote_metadata]"
        expect(response.body).to have_field "Rights Statement"
        expect(response.body).to have_field "Rights Note"
        expect(response.body).to have_field "Local identifier"
        expect(response.body).to have_selector "#scanned_map_append_id[value='#{parent.id}']", visible: false
        expect(response.body).to have_select "Collections", name: "scanned_map[member_of_collection_ids][]", options: [collection.title.first]
        expect(response.body).to have_field "Spatial"
        expect(response.body).to have_field "Temporal"
        expect(response.body).to have_select "Rights Statement", name: "scanned_map[rights_statement]", options: [""] + ControlledVocabulary.for(:rights_statement).all.map(&:label)
        expect(response.body).to have_field "Cartographic scale"
        expect(response.body).to have_checked_field "Open"
        expect(response.body).to have_button "Save"
      end
    end
  end

  describe "create" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:valid_params) do
      {
        title: ['Title 1', 'Title 2'],
        rights_statement: 'Test Statement',
        visibility: 'restricted'
      }
    end
    let(:invalid_params) do
      {
        title: [""],
        rights_statement: 'Test Statement',
        visibility: 'restricted'
      }
    end
    context "access control" do
      let(:params) { valid_params }
      it_behaves_like "an access controlled create request"
    end
    it "can create a map image" do
      post :create, params: { scanned_map: valid_params }

      expect(response).to be_redirect
      expect(response.location).to start_with "http://test.host/catalog/"
      id = response.location.gsub("http://test.host/catalog/", "").gsub("%2F", "/")
      expect(find_resource(id).title).to contain_exactly "Title 1", "Title 2"
    end
    context "when joining a collection" do
      let(:valid_params) do
        {
          title: ['Title 1', 'Title 2'],
          rights_statement: 'Test Statement',
          visibility: 'restricted',
          member_of_collection_ids: [collection.id.to_s]
        }
      end
      let(:collection) { FactoryGirl.create_for_repository(:collection) }
      it "works" do
        post :create, params: { scanned_map: valid_params }

        expect(response).to be_redirect
        expect(response.location).to start_with "http://test.host/catalog/"
        id = response.location.gsub("http://test.host/catalog/", "").gsub("%2F", "/")
        expect(find_resource(id).member_of_collection_ids).to contain_exactly collection.id
      end
    end
    context "when something goes wrong" do
      it "doesn't persist anything at all when it's solr erroring" do
        allow(Valkyrie::MetadataAdapter.find(:index_solr)).to receive(:persister).and_return(
          Valkyrie::MetadataAdapter.find(:index_solr).persister
        )
        allow(Valkyrie::MetadataAdapter.find(:index_solr).persister).to receive(:save_all).and_raise("Bad")

        expect do
          post :create, params: { scanned_map: valid_params }
        end.to raise_error "Bad"
        expect(Valkyrie::MetadataAdapter.find(:postgres).query_service.find_all.to_a.length).to eq 0
      end

      it "doesn't persist anything at all when it's postgres erroring" do
        allow(Valkyrie::MetadataAdapter.find(:postgres)).to receive(:persister).and_return(
          Valkyrie::MetadataAdapter.find(:postgres).persister
        )
        allow(Valkyrie::MetadataAdapter.find(:postgres).persister).to receive(:save).and_raise("Bad")
        expect do
          post :create, params: { scanned_map: valid_params }
        end.to raise_error "Bad"
        expect(Valkyrie::MetadataAdapter.find(:postgres).query_service.find_all.to_a.length).to eq 0
        expect(Valkyrie::MetadataAdapter.find(:index_solr).query_service.find_all.to_a.length).to eq 0
      end
    end
    it "renders the form if it doesn't create a map image" do
      post :create, params: { scanned_map: invalid_params }
      expect(response).to render_template "valhalla/base/new"
    end
  end

  describe "destroy" do
    let(:user) { FactoryGirl.create(:admin) }
    context "access control" do
      let(:factory) { :scanned_map }
      it_behaves_like "an access controlled destroy request"
    end
    it "can delete a book" do
      scanned_map = FactoryGirl.create_for_repository(:scanned_map)
      delete :destroy, params: { id: scanned_map.id.to_s }

      expect(response).to redirect_to root_path
      expect { query_service.find_by(id: scanned_map.id) }.to raise_error ::Valkyrie::Persistence::ObjectNotFoundError
    end
  end

  describe "edit" do
    let(:user) { FactoryGirl.create(:admin) }
    context "access control" do
      let(:factory) { :scanned_map }
      it_behaves_like "an access controlled edit request"
    end
    context "when a map image doesn't exist" do
      it "raises an error" do
        expect { get :edit, params: { id: "test" } }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      render_views
      it "renders a form" do
        scanned_map = FactoryGirl.create_for_repository(:scanned_map)
        get :edit, params: { id: scanned_map.id.to_s }

        expect(response.body).to have_field "Title", with: scanned_map.title.first
        expect(response.body).to have_button "Save"
      end
    end
  end

  describe "update" do
    let(:user) { FactoryGirl.create(:admin) }
    context "access control" do
      let(:factory) { :scanned_map }
      let(:extra_params) { { scanned_map: { title: ["Two"] } } }
      it_behaves_like "an access controlled update request"
    end
    context "when a map image doesn't exist" do
      it "raises an error" do
        expect { patch :update, params: { id: "test" } }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      it "saves it and redirects" do
        scanned_map = FactoryGirl.create_for_repository(:scanned_map)
        patch :update, params: { id: scanned_map.id.to_s, scanned_map: { title: ["Two"] } }

        expect(response).to be_redirect
        expect(response.location).to eq "http://test.host/catalog/#{scanned_map.id}"
        id = response.location.gsub("http://test.host/catalog/", "")
        reloaded = find_resource(id)

        expect(reloaded.title).to eq ["Two"]
      end
      it "renders the form if it fails validations" do
        scanned_map = FactoryGirl.create_for_repository(:scanned_map)
        patch :update, params: { id: scanned_map.id.to_s, scanned_map: { title: [""] } }

        expect(response).to render_template "valhalla/base/edit"
      end
      it_behaves_like "a workflow controller", :scanned_map
    end
  end

  describe "structure" do
    let(:user) { FactoryGirl.create(:admin) }
    context "when not logged in" do
      let(:user) { nil }
      it "redirects to login or root" do
        scanned_map = FactoryGirl.create_for_repository(:scanned_map)

        get :structure, params: { id: scanned_map.id.to_s }
        expect(response).to be_redirect
      end
    end
    context "when a map image doesn't exist" do
      it "raises an error" do
        expect { get :structure, params: { id: "banana" } }.to raise_error(Valkyrie::Persistence::ObjectNotFoundError)
      end
    end
    context "when it does exist" do
      render_views
      it "renders a structure editor form" do
        file_set = FactoryGirl.create_for_repository(:file_set)
        scanned_map = FactoryGirl.create_for_repository(
          :scanned_map,
          member_ids: file_set.id,
          logical_structure: [
            { label: 'testing', nodes: [{ label: 'Chapter 1', nodes: [{ proxy: file_set.id }] }] }
          ]
        )

        get :structure, params: { id: scanned_map.id.to_s }

        expect(response.body).to have_selector "li[data-proxy='#{file_set.id}']"
        expect(response.body).to have_field('label', with: 'Chapter 1')
        expect(response.body).to have_link scanned_map.title.first, href: solr_document_path(id: scanned_map.id)
      end
    end
  end

  def find_resource(id)
    query_service.find_by(id: Valkyrie::ID.new(id.to_s))
  end

  describe "GET /scanned_maps/:id/file_manager" do
    let(:user) { FactoryGirl.create(:admin) }

    context "when an admin and with an image file" do
      let(:file_metadata) { FileMetadata.new(use: [Valkyrie::Vocab::PCDMUse.OriginalFile], mime_type: 'image/tiff') }

      it "sets the record and children variables" do
        child = FactoryGirl.create_for_repository(:file_set, file_metadata: [file_metadata])
        parent = FactoryGirl.create_for_repository(:scanned_map, member_ids: child.id)
        get :file_manager, params: { id: parent.id }

        expect(assigns(:change_set).id).to eq parent.id
        expect(assigns(:children).map(&:id)).to eq [child.id]
      end
    end

    context "when an admin and with an fgdc metadata file" do
      let(:file_metadata) { FileMetadata.new(use: [Valkyrie::Vocab::PCDMUse.OriginalFile], mime_type: 'application/xml; schema=fgdc') }

      it "sets the record and metadata children variables" do
        child = FactoryGirl.create_for_repository(:file_set, file_metadata: [file_metadata])
        parent = FactoryGirl.create_for_repository(:scanned_map, member_ids: child.id)
        get :file_manager, params: { id: parent.id }

        expect(assigns(:change_set).id).to eq parent.id
        expect(assigns(:metadata_children).map(&:id)).to eq [child.id]
      end
    end
  end

  describe "GET /concern/scanned_maps/:id/manifest" do
    let(:file) { fixture_file_upload('files/example.tif', 'image/tiff') }
    it "returns a IIIF manifest for a resource with a file" do
      scanned_map = FactoryGirl.create_for_repository(:scanned_map, files: [file])

      get :manifest, params: { id: scanned_map.id.to_s, format: :json }
      manifest_response = MultiJson.load(response.body, symbolize_keys: true)

      expect(response.headers["Content-Type"]).to include "application/json"
      expect(manifest_response[:sequences].length).to eq 1
      expect(manifest_response[:viewingHint]).to eq "individuals"
    end
  end

  # Tests functionality defined in `app/controllers/concerns/geo_resource_controller.rb`
  #   Acts as a 'master spec' in this regard
  describe "PUT /concern/scanned_maps/:id/extract_metadata/:file_set_id" do
    let(:user) { FactoryGirl.create(:admin) }
    let(:file) { fixture_file_upload('files/geo_metadata/fgdc.xml', 'application/xml') }
    let(:tika_output) { tika_xml_output }

    it "extracts fgdc metadata into scanned map" do
      scanned_map = FactoryGirl.create_for_repository(:scanned_map, files: [file])

      put :extract_metadata, params: { id: scanned_map.id.to_s, file_set_id: scanned_map.member_ids.first.to_s }
      expect(query_service.find_by(id: scanned_map.id).title).to eq ["China census data by county, 2000-2010"]
    end
  end
end
