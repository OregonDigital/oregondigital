class ReviewerController < CatalogController
  before_filter :restrict_to_reviewer

  # Undo Catalog restrictions
  self.solr_search_params_logic -= [:add_access_controls_to_solr_params, :exclude_unreviewed_items]
  self.solr_search_params_logic += [:exclude_reviewed]

  def index
    params[:search_field] ||= "all_fields"
    params[:q] ||= ""
    super
  end

  private

  def exclude_reviewed(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:\"true\""
  end

  # Override base list of unwanted models to allow sets (GenericCollection)
  # while still avoiding the Template type
  def unwanted_models
    return [Template]
  end

  def restrict_to_reviewer
    unless can? :review, GenericAsset
      raise Hydra::AccessDenied.new "You do not have permission to review."
    end
  end

end
