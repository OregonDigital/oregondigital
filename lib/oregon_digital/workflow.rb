module OregonDigital
  module Workflow
    extend ActiveSupport::Concern

    included do
      has_metadata :name => 'workflowMetadata', :type => Datastream::Yaml
      after_initialize :reset_workflow, :if => :new_record?

      class << self
        def reviewed
          all.select { |o| o.reviewed? }
        end
      end
    end

    def reset_workflow
      self.read_groups = ["admin", "archivist"]
      workflowMetadata.reviewed = false
      workflowMetadata.has_thumbnail = false
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
      solr_doc["has_thumbnail_bs"] = !!workflowMetadata.has_thumbnail
      super
    end
  end
end
