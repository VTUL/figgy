# frozen_string_literal: true
class PlumChangeSetPersister
  class CreateFile
    class Factory
      attr_reader :file_appender
      def initialize(file_appender: FileAppender)
        @file_appender = file_appender
      end

      def new(**args)
        CreateFile.new(args.merge(file_appender: file_appender))
      end
    end
    attr_reader :change_set_persister, :change_set, :file_appender
    delegate :persister, :storage_adapter, to: :change_set_persister
    def initialize(change_set_persister:, change_set:, post_save_resource: nil, file_appender:)
      @change_set = change_set
      @change_set_persister = change_set_persister
      @file_appender = file_appender
    end

    def run
      appender = file_appender.new(storage_adapter: storage_adapter, persister: persister, files: files)
      change_set_persister.created_file_sets = appender.append_to(change_set.resource)
    end

    def files
      change_set.try(:files) || []
    end
  end
end
