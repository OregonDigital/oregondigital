module OregonDigital::Workflow
  module SoftDestroy
    def soft_destroy
      workflowMetadata.destroyed = true
      workflowMetadata.destroyed_at = Time.current.iso8601
      reset_workflow!
    end

    def undelete
      workflowMetadata.destroyed = false
    end

    def undelete!
      undelete
      save
    end

    def soft_destroyed?
      !!workflowMetadata.destroyed
    end
  end
end
