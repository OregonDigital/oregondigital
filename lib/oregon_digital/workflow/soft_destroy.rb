module OregonDigital::Workflow
  module SoftDestroy
    def soft_destroy
      workflowMetadata.destroyed = true
      workflowMetadata.destroyed_at = Time.current.iso8601
      save
    end

    def destroyed?
      !!workflowMetadata.destroyed
    end
  end
end
