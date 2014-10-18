module OregonDigital::RDF
  class CompoundResource < ActiveFedora::Rdf::Resource
    configure :type => RDF::URI("http://opaquenamespace.org/ns/compoundObject")
    property :references, :predicate => RDF::DC.references, :class_name => ::GenericAsset
    property :title, :predicate => RDF::DC.title

    alias_method :orig_title, :title

    def title
      return reference_title if reference_title.present? && orig_title.blank?
      orig_title
    end

    def references_pids
      @references_pids ||= query([rdf_subject, RDF::DC.references, nil]).map{|x| x.object.to_s.split("/").last}
    end

    def pid
      references_pids.first
    end

    def first_reference
      references.first
    end

    def cached_reference
      @cached_reference ||= begin
                              ActiveFedora::Base.load_instance_from_solr(pid)
                            rescue ActiveFedora::ObjectNotFoundError
                              nil
                            end
    end

    def solrize
      fields.map{|field| {field.to_sym => solrize_field(field)}}.inject(&:merge)
    end

    def solrize_field(field)
      if respond_to?("#{field}_solrize")
        send("#{field}_solrize")
      else
        send("#{field}")
      end
    end

    def references_solrize
      references.map{|x| x.resource.rdf_subject}
    end
    
    private


    def reference_title
      Array.wrap(cached_reference.title) if cached_reference.respond_to?(:title)
    end
  end
end
