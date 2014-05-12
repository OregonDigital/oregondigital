# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document

  use_extension( OregonDigital::SolrNTripleExtension)
end
