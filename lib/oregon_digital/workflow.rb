module OregonDigital
  module Workflow
    extend ActiveSupport::Concern

    included do
      include SoftDestroy
      has_metadata :name => 'workflowMetadata', :type => Datastream::Yaml
      after_initialize :reset_workflow, :if => :new_record?

      class << self
        def reviewed
          where(ActiveFedora::SolrService.solr_name(:reviewed, :symbol) => "true")
        end
      end
    end

    def reset_workflow
      reset_read_permissions
      workflowMetadata.reviewed = false
      workflowMetadata.has_thumbnail = false
    end

    def reset_read_permissions
      self.read_groups = ["admin", "archivist"]
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
