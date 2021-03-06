# frozen_string_literal: true
class PlumChangeSetPersister
  class PropagateVisibilityAndState
    attr_reader :change_set_persister, :change_set
    delegate :query_service, :persister, to: :change_set_persister
    def initialize(change_set_persister:, change_set:, post_save_resource: nil)
      @change_set = change_set
      @change_set_persister = change_set_persister
    end

    def run
      return if !change_set.changed?(:visibility) && !change_set.changed?(:state)
      members.each do |member|
        member.read_groups = change_set.read_groups if change_set.read_groups
        member.state = change_set.state if should_set_state?(member)
        persister.save(resource: member)
      end
    end

    def should_set_state?(member)
      change_set.state && member.respond_to?(:state) && valid_states(member).include?(change_set.state)
    end

    def members
      found = query_service.find_members(resource: change_set.resource) || []
      found.select do |x|
        !x.is_a?(FileSet)
      end
    end

    def valid_states(member)
      DynamicChangeSet.new(member).workflow_class.new(nil).valid_states
    end
  end
end
