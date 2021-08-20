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

  # copied from Blacklight::SolrHelper 4.6.3 to get http_method fix.
  def query_solr(user_params = params || {}, extra_controller_params = {})
    # In later versions of Rails, the #benchmark method can do timing
    # better for us.
    bench_start = Time.now
    solr_params = self.solr_search_params(user_params).merge(extra_controller_params)
    solr_params[:qt] ||= blacklight_config.qt
    path = blacklight_config.solr_path

    # delete these parameters, otherwise rsolr will pass them through.
    key = blacklight_config.http_method == :post ? :data : :params
    res = blacklight_solr.send_and_receive(path, {key=>solr_params, method:blacklight_config.http_method})

    solr_response = Blacklight::SolrResponse.new(force_to_utf8(res), solr_params)

    Rails.logger.debug("Solr query: #{solr_params.inspect}")
    Rails.logger.debug("Solr response: #{solr_response.inspect}") if defined?(::BLACKLIGHT_VERBOSE_LOGGING) and ::BLACKLIGHT_VERBOSE_LOGGING
    Rails.logger.debug("Solr fetch: #{self.class}#query_solr (#{'%.1f' % ((Time.now.to_f - bench_start.to_f)*1000)}ms)")


    solr_response
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
