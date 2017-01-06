# -*- encoding : utf-8 -*-
class SolrDocument 
  include Blacklight::Solr::Document

  use_extension( OregonDigital::SolrNTripleExtension)

  def to_model
    return ActiveFedora::Base.load_instance_from_solr(self["id"], self)
  end
end
