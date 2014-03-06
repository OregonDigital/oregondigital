module OregonDigital
  module Workflow
    extend ActiveSupport::Concern

    included do
      has_metadata :name => 'workflowMetadata', :type => Datastream::Yaml
      after_initialize :reset_workflow, :if => :new_record?
    end

    def reset_workflow
      self.read_groups = ["admin"]
      workflowMetadata.reviewed = false
    end

    def reset_workflow!
      reset_workflow
      save!
    end

    def reviewed?
      workflowMetadata.reviewed
    end

    def review
      self.read_groups |= ["public"]
      workflowMetadata.reviewed = true
    end

    def review!
      review
      save!
    end

    def to_solr(solr_doc={})
      Solrizer.set_field(solr_doc, :reviewed, (!!workflowMetadata.reviewed).to_s, :symbol)
      super
    end
  end
end
