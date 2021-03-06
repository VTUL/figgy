# frozen_string_literal: true
require 'rails_helper'

RSpec.describe VectorWorkChangeSet do
  subject(:change_set) { described_class.new(form_resource) }
  let(:vector_work) { VectorWork.new(title: 'Test', rights_statement: 'Stuff', visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE, state: 'pending') }
  let(:form_resource) { vector_work }
  before do
    stub_bibdata(bib_id: '6592452')
  end

  describe "#workflow" do
    it "has a workflow" do
      change_set.prepopulate!
      expect(change_set.workflow).to be_a(BookWorkflow)
      expect(change_set.workflow.pending?).to be true
    end
  end

  describe "validations" do
    it "is valid by default" do
      expect(change_set).to be_valid
    end
    context "when neither title or metadata identifier is set" do
      let(:form_resource) { vector_work.new(title: "", source_metadata_identifier: "") }
      it "is invalid" do
        expect(change_set).not_to be_valid
      end
    end
    context "when title is an empty array" do
      it "is invalid" do
        expect(change_set.validate(title: [""])).to eq false
      end
    end
    context "when only metadata_identifier is set" do
      let(:form_resource) { vector_work.new(title: "", source_metadata_identifier: "6592452") }
      it "is valid" do
        expect(change_set).to be_valid
      end
    end
    context "when rights_statement isn't set" do
      let(:form_resource) { vector_work.new(rights_statement: [""]) }
      it "is invalid" do
        expect(change_set).not_to be_valid
      end
    end
    context "when visibility isn't set" do
      let(:form_resource) { vector_work.new(visibility: [""]) }
      it "is invalid" do
        expect(change_set).not_to be_valid
      end
    end
    context "when given a valid state transition" do
      it "is valid" do
        change_set.validate(state: "metadata_review")
        expect(change_set).to be_valid
      end
    end
    context "when given an invalid state transition" do
      it "is invalid" do
        change_set.validate(state: "complete")
        expect(change_set).not_to be_valid
      end
    end
  end

  describe "#holding_location" do
    it "converts values to RDF::URIs" do
      change_set.prepopulate!
      change_set.validate(holding_location: "http://test.com/")
      expect(change_set.holding_location).to be_instance_of RDF::URI
    end
  end

  describe "#rights_statement" do
    let(:form_resource) { VectorWork.new(rights_statement: RDF::URI("http://rightsstatements.org/vocab/NKC/1.0/")) }
    it "is singular, required, and converts to an RDF::URI" do
      change_set.prepopulate!

      expect(change_set.rights_statement).to eq RDF::URI("http://rightsstatements.org/vocab/NKC/1.0/")
      change_set.validate(rights_statement: "")
      expect(change_set).not_to be_valid
      change_set.validate(rights_statement: "http://rightsstatements.org/vocab/NKC/1.0/")
      expect(change_set.rights_statement).to be_instance_of RDF::URI
    end
    context "when given a blank VectorWork" do
      let(:form_resource) { VectorWork.new }
      it "sets a default Rights Statement" do
        change_set.prepopulate!

        expect(change_set.rights_statement).to eq RDF::URI("http://rightsstatements.org/vocab/NKC/1.0/")
      end
    end
  end

  describe "#workflow" do
    it "has a workflow" do
      change_set.prepopulate!
      expect(change_set.workflow).to be_a(BookWorkflow)
      expect(change_set.workflow.pending?).to be true
    end
  end

  describe "#apply_remote_metadata_directly?" do
    it "applies remote metadata directly to the model" do
      expect(change_set.apply_remote_metadata_directly?).to be true
    end
  end
end
