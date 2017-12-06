require 'rails_helper'
include ActionDispatch::TestProcess

RSpec.describe "catalog/_index_default.html.erb" do
  context "when given a Scanned Resource" do
    let(:document) { SolrDocument.new(Valkyrie::MetadataAdapter.find(:index_solr).resource_factory.from_resource(resource: scanned_resource)) }
    let(:scanned_resource) { FactoryGirl.create_for_repository(:scanned_resource, depositor: "awesomeness") }
    before do
      allow(view).to receive(:document).and_return(document)
      stub_blacklight_views
      render
    end
    it "displays the depositor" do
      expect(rendered).to have_content "awesomeness"
    end
    context "when the document has files" do
      let(:scanned_resource) { FactoryGirl.create_for_repository(:scanned_resource, depositor: "awesomeness", files: [file1, file2]) }
      let(:file1) { fixture_file_upload('files/example.tif', 'image/tiff') }
      let(:file2) { fixture_file_upload('files/example.tif', 'image/tiff') }
      it "displays the number of files" do
        expect(rendered).to have_content "File Count"
        expect(rendered).to have_content(2)
      end
    end
  end
end
