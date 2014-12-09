class DestroyedController < CatalogController
  before_filter :restrict_to_destroyers
  
  # Undo Catalog restrictions
  self.solr_search_params_logic -= [:add_access_controls_to_solr_params, :exclude_unreviewed_items, :exclude_destroyed_items]
  self.solr_search_params_logic += [:require_destroyed_items]

  def index
    params[:search_field] ||= "all_fields"
    params[:q] ||= ""
    super
  end

  def undelete
    asset.undelete!
    flash[:notice] = I18n.t('oregondigital.destroyed.undelete.success')
    redirect_to catalog_path(asset) 
  end

  private

  def asset
    @asset ||= GenericAsset.find(params[:id])
  end

  def require_destroyed_items(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{ActiveFedora::SolrService.solr_name("workflow_metadata__destroyed", :symbol)}:\"true\""
  end

  # Override base list of unwanted models to allow sets (GenericCollection)
  # while still avoiding the Template type
  def unwanted_models
    return [Template]
  end

  def restrict_to_destroyers
    unless can? :destroy, GenericAsset
      raise Hydra::AccessDenied.new I18n.t('oregondigital.destroyed.unauthorized')
    end
  end
end
