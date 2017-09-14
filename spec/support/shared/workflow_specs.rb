RSpec.shared_examples "a workflow controller" do |factory_resource|
  it "can create a workflow note" do
    resource = FactoryGirl.create_for_repository(factory_resource)

    patch :update, params: { id: resource.id.to_s, resource.model_name.singular.to_sym => { new_workflow_note_attributes: { note: "Test", author: "Shakespeare" } } }

    reloaded = find_resource(resource.id)
    expect(reloaded.workflow_note.first.author).to eq ["Shakespeare"]
    expect(reloaded.workflow_note.first.note).to eq ["Test"]
  end
  it "doesn't create a workflow note with an empty note" do
    resource = FactoryGirl.create_for_repository(factory_resource)

    patch :update, params: { id: resource.id.to_s, resource.model_name.singular.to_sym => { new_workflow_note_attributes: { author: "Test" } } }

    reloaded = find_resource(resource.id)
    expect(reloaded.workflow_note).to be_blank
  end
  it "doesn't create a workflow note without an author" do
    resource = FactoryGirl.create_for_repository(factory_resource)

    patch :update, params: { id: resource.id.to_s, resource.model_name.singular.to_sym => { new_workflow_note_attributes: { note: "Test" } } }

    reloaded = find_resource(resource.id)
    expect(reloaded.workflow_note).to be_blank
  end

  def find_resource(id)
    query_service.find_by(id: Valkyrie::ID.new(id.to_s))
  end

  def query_service
    Valkyrie.config.metadata_adapter.query_service
  end
end
