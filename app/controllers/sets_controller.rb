class SetsController < CatalogController

  self.solr_search_params_logic += [:require_set]

  before_filter :strip_facets

  def index
    @collections = sets.sort_by {|s| s.title.sub(/^(the|a|an)\s+/i, '')}
    @collection = set
    super
  end

  def search_action_url(options={})
    sets_path(options.merge(:set => set))
  end

  private

  def sets
    @sets ||= GenericCollectionDecorator.decorate_collection(collections)
  end

  def collections
    set_pids.map{|pid| GenericCollection.load_instance_from_solr(pid)}
  end

  def set_pids
    Blacklight.solr.get("select", :params => {:qt => "search", :q => "has_model_ssim:#{RSolr.escape("info:fedora/afmodel:GenericCollection")}", :fl => "id", :rows => 100})["response"]["docs"].map{|x| x["id"]}
  end

  def set
    @set ||= sets.find{|x| x.pid.downcase == OregonDigital::IdService.namespaceize(params[:set]).downcase}
  end

  def require_set(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "+#{ActiveFedora::SolrService.solr_name("desc_metadata__set",:facetable)}:\"#{set.resource.rdf_subject}\"" if set
  end

  def strip_facets
    if set
      self.blacklight_config.facet_fields.except!(ActiveFedora::SolrService.solr_name("desc_metadata__set", :facetable))
    end
  end

end
