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
      @compound_parent ||= GenericAsset.where(Solrizer.solr_name("desc_metadata__od_content", :symbol).to_sym => resource.rdf_subject.to_s).first.adapt_to_cmodel
    end

  end
end
