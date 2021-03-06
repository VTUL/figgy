# frozen_string_literal: true
require 'rails_helper'

RSpec.describe OsdModalHelper do
  describe "#osd_modal_for" do
    context "when not given an ID" do
      it "yields" do
        output = helper.osd_modal_for(nil) do
          "bla"
        end
        expect(output).to eq "bla"
      end
    end
    context "when encountering an error retrieving the derivative" do
      let(:file_set) { FactoryBot.create_for_repository(:file_set) }
      let(:manifest_helper_class) { class_double(ManifestBuilder::ManifestHelper).as_stubbed_const(transfer_nested_constants: true) }
      let(:manifest_helper) { instance_double(ManifestBuilder::ManifestHelper) }
      before do
        allow(manifest_helper_class).to receive(:new).and_return(manifest_helper)
        allow(manifest_helper).to receive(:manifest_image_path).and_raise(Valkyrie::Persistence::ObjectNotFoundError)
      end
      it 'generates an empty <span>' do
        expect(helper.osd_modal_for(file_set.id)).to eq "<span></span>"
      end
    end
  end

  describe "#build_thumbnail_path" do
    context "when encountering an error finding a derivative" do
      it "generates a default image" do
        expect(helper.build_thumbnail_path("bad")).to eq helper.image_tag('default.png')
      end
    end
  end

  describe "#figgy_thumbnail_path" do
    context "when given a two-level deep resource" do
      before do
        allow(Valkyrie.logger).to receive(:warn).and_return(nil)
      end
      it "uses the fileset thumbnail ID" do
        file_set = FactoryBot.create_for_repository(:file_set)
        book = FactoryBot.create_for_repository(:scanned_resource, thumbnail_id: file_set.id)
        parent_book = FactoryBot.create_for_repository(:scanned_resource, thumbnail_id: book.id)

        expect(helper.figgy_thumbnail_path(parent_book)).to include file_set.id.to_s
      end
      it "returns nothing when the fileset doesn't exist" do
        book = FactoryBot.create_for_repository(:scanned_resource, thumbnail_id: Valkyrie::ID.new("busted"))
        parent_book = FactoryBot.create_for_repository(:scanned_resource, thumbnail_id: book.id)

        expect(helper.figgy_thumbnail_path(parent_book)).to eq nil
      end
    end
  end
end
