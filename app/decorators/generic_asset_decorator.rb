# View-specific logic for the solr documents that the CatalogController creates
class GenericAssetDecorator < Draper::Decorator
  delegate_all

  # Figures out how this asset needs to be viewed when rendered by itself (i.e., probably won't
  # want to use this on the search index)
  def view_partial
    "generic_viewer"
  end

  def sorted_show_fields
    (configured_show_keys | property_keys).compact.select{|x| display_field?(x)}
  end

  def display_field?(field)
    return false if field_values(field).blank?
    true
  end

  def field_label(field)
    OregonDigital::Metadata::FieldTypeLabel.for(field)
  end

  def field_values(field)
    if field == "od_content"
      return
    end
    results ||= resource.get_values(field)
    results.map {|r| field_value_to_string(field, r)}.reject {|val| val.blank?}
  end

  def compound_list
    list = []
    if compound?
      list << self
      list |= pull_cpd_objects(slice_list(cpd_pids))
    elsif compound_parent
      list << compound_parent
      list |= pull_cpd_objects( slice_list(compound_parent.cpd_pids) )
    end
    list
  end

  private

  def slice_list(list)
    return [] unless !list.nil?
    asset = 1
    max = 40
    half = max/2
    if list.size <= max + asset
      return list
    end

    if compounded?
      index = list.find_index(self.pid)
      start = get_start(list.size, max, index)
      shortlist = list.slice(start, max + asset)
    else
      shortlist = list.slice(0, max)
    end
    shortlist
  end

  def get_start(list_size, max, index)
    asset = 1
    leftindex = index-(max/2)
    rightindex = index + (max/2)
    if leftindex < 0
      leftindex = 0
    elsif rightindex >= list_size
      leftindex = list_size - ( max + asset )
    end
    leftindex
  end

  def pull_cpd_objects(list)
    return [] unless !list.nil?
    od_cpd_contents = []
    list.each do |pid|
      begin
        od_cpd_contents << ActiveFedora::Base.load_instance_from_solr(pid)
      rescue  ActiveFedora::ObjectNotFoundError
        OregonDigital::RDF::ObjectResource.new(pid)
      end
    end
    od_cpd_contents
  end

  def field_value_to_string(field, value)
    # CV fields will always have a resource and the resource will always have a
    # label, so we can safely assume we have no CV field unless those exist
    value = value.resource if value.respond_to?(:resource)
    return value.to_s unless value.respond_to?(:rdf_label)
    return "" if value.rdf_label.first.to_s == value.rdf_subject || value.rdf_label.first.blank?
    # Figure out the CV facet to use here
    facet_field_name = Solrizer.solr_name("desc_metadata__#{field}_label", :facetable)
    facet_label = value.solrize.find{|x| x.kind_of?(Hash) && x.include?(:label)}
    facet_label = facet_label[:label] if facet_label
    path = h.catalog_index_path(:f => {facet_field_name => [facet_label]})
    return h.link_to(value.rdf_label.first.to_s, path)
  end

  def property_keys
    r = resource.send(:properties).keys
  end

  def configured_show_keys
    r = I18n.t("oregondigital.metadata")
    r = {} unless r.kind_of?(Hash)
    r.keys.map{|x| x.to_s}
  end

end
