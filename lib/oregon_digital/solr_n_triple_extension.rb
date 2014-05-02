module OregonDigital
  module SolrNTripleExtension
    def self.extended(document)
      document.will_export_as(:nt, "text/n3")
    end
    def export_as_nt
      object = ActiveFedora::Base.load_instance_from_solr(self["id"])
      object.resource.dump(:ntriples)
    end
  end
end
