module OregonDigital
  module Compound
    extend ActiveSupport::Concern
    
    def compound?
      od_content.length > 0
    end

    def od_content
      @od_content ||= descMetadata.od_content.first_or_create
    end

    def compound_parent
      @compound_parent ||= ActiveFedora::Base.where(Solrizer.solr_name("desc_metadata__od_content_references", :symbol).to_sym => resource.rdf_subject.to_s).first.try(:adapt_to_cmodel)
    end

    def compounded?
      compound_parent.present?
    end

  end
end
