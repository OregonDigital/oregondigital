module AdvancedSearchPatch
  def get_advanced_search_facets
    search_context_params = {}
    adv_keys = blacklight_config.search_fields.keys.map{|k| k.to_sym}
    trimmed_params = params.reject do |k, v|
      adv_keys.include?(k.to_sym)
    end
    trimmed_params.delete(:f_inclusive)
    search_context_params = solr_search_params(trimmed_params)
    if advanced_search_context.length > 0
      search_context_params.delete(:q)
      search_context_params.delete('q')
      search_context_params.delete_if do |k, v|
        k = k.to_s
        (["facet.limit", "facet.sort", "f", "facets", "facet.fields", "per_page"].include?(k) ||                
         k =~ /f\..+\.facet\.limit/ ||
         k =~ /f\..+\.facet\.sort/
        )
      end
    end
    input = HashWithIndifferentAccess.new
    input.merge!(search_context_params)
    input[:per_page] = 0
    input[:qt] = blacklight_config.advanced_search[:qt] if blacklight_config.advanced_search[:qt]
    input.merge!(blacklight_config.advanced_search[:form_solr_parameters]) if blacklight_config.advanced_search[:form_solr_parameters]
    input[:q] ||= '{!lucene}*:*'
    find(nil, input.to_hash)
  end
end
module BlacklightAdvancedSearch::RenderConstraintsOverride
  def render_constraints_filters(my_params = params)
    content = super(my_params)

    if (@advanced_query)
      @advanced_query.filters.each_pair do |field, value_list|
        label = facet_field_labels[field]
        content << render_constraint_element(label,
                                             controlled_view_label(value_list).join(" OR "),
                                             :remove => catalog_index_path( remove_advanced_filter_group(field, my_params) )
                                            )
      end
    end

    return content
  end
end
Rails.application.config.after_initialize do
  AdvancedController.send(:include, AdvancedSearchPatch)
end
