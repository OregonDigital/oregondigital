# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  # Include Oregon Digital Catalog Logic
  include OregonDigital::Catalog::Defaults
  include OregonDigital::Catalog::ViewConfiguration
  include OregonDigital::Catalog::Facets
  include OregonDigital::Catalog::IndexFields
  include OregonDigital::Catalog::SearchFields
  include OregonDigital::Catalog::SortFields
  include OregonDigital::Catalog::Decorators

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show

  # This applies appropriate access controls to all solr queries
  self.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  self.solr_search_params_logic += [:exclude_unwanted_models]
  # Filter out unreviewed items.
  self.solr_search_params_logic += [:exclude_unreviewed_items]
  # Filter out destroyed items.
  self.solr_search_params_logic += [:exclude_destroyed_items]

  rescue_from Hydra::AccessDenied do |exception|
    unless request["id"].nil?
      asset = ActiveFedora::Base.find(request["id"])
      if ((asset.read_groups.include? "University-of-Oregon") || (asset.read_groups.include? "Oregon-State-University") )
        return redirect_to root_url, :alert => "Requested asset is restricted to university use on campus; if accessing Oregon Digital from off-campus, please use VPN."
      end
    end
    if current_user and current_user.persisted?
      redirect_to root_url, :alert => exception.message
    else
      redirect_to new_user_session_url, :alert => exception.message
    end
  end

  private

  def exclude_unwanted_models(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    unwanted_models.each do |model|
      solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name("active_fedora_model", :stored_sortable)}:\"#{model.to_s}\""
    end
  end

  def exclude_unreviewed_items(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name(:reviewed, :symbol)}:\"false\""
  end

  def exclude_destroyed_items(solr_parameters, user_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{ActiveFedora::SolrService.solr_name("workflow_metadata__destroyed", :symbol)}:\"true\""
  end

  # Array of models to exclude from catalog results.
  def unwanted_models
    [
      GenericCollection,
      Template
    ]
  end

end
