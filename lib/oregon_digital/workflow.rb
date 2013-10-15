require_relative "app/models/datastreams/yaml_datastream.rb"

module OregonDigital
  module Workflow
    extend ActiveSupport::Concern

    included do
      has_metadata :name => 'workflowMetadata', :type => YamlDatastream
      after_initialize :reset_workflow, :if => :new_record?
    end

    def reset_workflow
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
