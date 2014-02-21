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
  include OregonDigital::Catalog::Decorators

  # These before_filters apply the hydra access controls
  before_filter :enforce_show_permissions, :only=>:show

  # This applies appropriate access controls to all solr queries
  self.solr_search_params_logic += [:add_access_controls_to_solr_params]
  # This filters out objects that you want to exclude from search results, like FileAssets
  self.solr_search_params_logic += [:exclude_unwanted_models]
  # Filter out unreviewed items.
  self.solr_search_params_logic += [:exclude_unreviewed_items]

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

  # Array of models to exclude from catalog results.
  def unwanted_models
    [
      GenericCollection,
      Template
    ]
  end

end
