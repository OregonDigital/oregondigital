module CollectionsHelper
  def collection_name(pid)
    GenericCollection.load_instance_from_solr(pid).decorate.title
  end
end