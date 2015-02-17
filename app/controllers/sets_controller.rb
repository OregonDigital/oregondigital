class SetsController < CatalogController

  self.solr_search_params_logic += [:require_set]

  before_filter :strip_facets

  def index
    if params[:set]
      @collection = set
    else
      @collections = sets.sort_by {|s| s.title.sub(/^(the|a|an)\s+/i, '')}
    end
    super
  end

  def search_action_url(options={})
    return sets_path(options.merge(:set => @collection)) if @collection
    return root_path
  end

  private

  def sets
    @sets ||= GenericCollectionDecorator.decorate_collection(collections)
  end

  def collections
    set_pids.map{|pid| GenericCollection.load_instance_from_solr(pid["id"], pid)}
  end

  def set_pids
    @set_pids ||= ActiveFedora::SolrService.query("has_model_ssim:#{RSolr.escape("info:fedora/afmodel:GenericCollection")} AND reviewed_ssim:true", :rows => 100000)
  end

  def set
    return nil unless params[:set]
    @set ||= GenericCollection.load_instance_from_solr(OregonDigital::IdService.namespaceize(params[:set]).downcase).decorate
  end

  def require_set(solr_parameters, user_parameters)
    return unless params[:set]
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "+#{ActiveFedora::SolrService.solr_name("desc_metadata__set",:facetable)}:\"#{set.resource.rdf_subject}\"" if set
  end

  def strip_facets
    if params[:set] && set
      self.blacklight_config.facet_fields.except!(ActiveFedora::SolrService.solr_name("desc_metadata__set", :facetable))
    end
  end

end
