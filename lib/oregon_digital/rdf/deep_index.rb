module OregonDigital::RDF
  module DeepIndex
    def solrize
      return super if node?
      [rdf_subject.to_s, {:label => "#{rdf_label.first.to_s}$#{rdf_subject.to_s}"}]
    end
  end
end
