module CollectionsHelper
  def collection_name(pid)
    GenericCollection.load_instance_from_solr(pid).decorate.title
  end
  def render_set(set)
    renderer = SetRenderer.new(set, lookup_context, params)
    render :template => renderer.partial_name
  end
end