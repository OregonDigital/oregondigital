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
