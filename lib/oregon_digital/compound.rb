module OregonDigital
  module Compound
    extend ActiveSupport::Concern
    included do
      before_save :persist_od_content
    end
    
    def compound?
      od_content.length > 0
    end

    def od_content
      @od_content ||= descMetadata.od_content.first || OregonDigital::RDF::List.from_uri(::RDF::Node.new, resource)
      persist_od_content
      @od_content
    end

    def persist_od_content
      descMetadata.od_content = [@od_content] if @od_content && descMetadata.od_content.first.nil? && @od_content.to_a.length > 0
    end

    def compound_parent
      @compound_parent ||= ActiveFedora::Base.where(Solrizer.solr_name("desc_metadata__od_content_references", :symbol).to_sym => resource.rdf_subject.to_s).first.try(:adapt_to_cmodel)
    end

    def compounded?
      compound_parent.present?
    end

  end
end
