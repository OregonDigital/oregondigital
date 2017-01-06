# -*- encoding : utf-8 -*-
class SolrDocument 
  include Blacklight::Solr::Document

  use_extension( OregonDigital::SolrNTripleExtension)

  # Returns the ActiveFedora model from this document; we don't create a proper
  # to_model method here, because there's some magic somewhere that to_model
  # ends up breaking which is more broken than what to_model fixes.
  def get_af_model
    return ActiveFedora::Base.load_instance_from_solr(self["id"], self)
  end
end
