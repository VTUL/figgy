# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Collection do
  subject(:collection) { FactoryBot.build(:collection) }
  it "has a title" do
    collection.title = "Test"
    expect(collection.title).to eq ["Test"]
  end
  it "has a slug" do
    collection.slug = "test"
    expect(collection.slug).to eq ["test"]
  end
  it "has a description" do
    collection.description = "test"
    expect(collection.description).to eq ["test"]
  end
  it "has visibility" do
    collection.visibility = "open"
    expect(collection.visibility).to eq ["open"]
  end
  it "has a local_identifier" do
    expect(collection.local_identifier).to eq []
    collection.local_identifier = "test"
    expect(collection.local_identifier).to eq ["test"]
  end
end
