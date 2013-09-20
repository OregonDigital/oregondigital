module OregonDigital
  module Workflow
    extend ActiveSupport::Concern

    included do
      has_metadata :name => 'workflowMetadata', :type =>
        YamlDatastream

      after_initialize :reset_workflow, :if => :new_record?
    end

    def reset_workflow(persist = false)
      workflowMetadata.reviewed = false
      save if persist
    end

    def reset_workflow!
      reset_workflow(true)
    end

    def reviewed?
      workflowMetadata.reviewed
    end

    def review(persist = false)
      workflowMetadata.reviewed = true
      save if persist
    end

    def review!
      review(true)
    end
  end
end
