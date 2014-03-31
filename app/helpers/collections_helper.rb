module CollectionsHelper
  # Force Blacklight's facet stuff to load first so we can override its methods
  include Blacklight::FacetsHelperBehavior

  def controlled_view(pid)
    # Find documents which have info about this pid.
    return controlled_view_label(pid).find{|x| !x.blank?}.to_s
  end

  def controlled_view_label(label)
    return controlled_view_label(label[:document][label[:field]]) if label.kind_of?(Hash)
    Array.wrap(label).map do |x|
      new_label = x.split("$")
      if new_label.first == new_label.last
        ""
      else
        new_label.first.strip
      end
    end
  end

  def render_set(set)
    renderer = SetRenderer.new(set, lookup_context, params)
    render :template => renderer.partial_name
  end

  def add_facet_params_and_redirect(field, item)
    if field == ActiveFedora::SolrService.solr_name("desc_metadata__set_label", :facetable) && params[:search_field].blank? && params[:f].blank?
      {
          :controller => "sets",
          :action => "index",
          :set => GenericCollection.id_param(item.split("$").last)
      }
    else
      super
    end
  end

end
