class SetsController < CatalogController

  self.solr_search_params_logic += [:require_set]

  def index
    @collections = sets
    @collection = set
    super
  end

  private

  def sets
    @sets ||= GenericCollectionDecorator.decorate_collection(GenericCollection.all)
  end

  def set
    @set ||= sets.find{|x| x.pid.downcase == OregonDigital::IdService.namespaceize(params[:set]).downcase}
  end

  def require_set(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "+#{ActiveFedora::SolrService.solr_name("desc_metadata__set",:facetable)}:\"#{set.pid}\"" if set
  end

end
