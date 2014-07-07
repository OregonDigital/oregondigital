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
    results = resource.get_values(field)
    results.map {|r| field_value_to_string(field, r)}.reject {|val| val.blank?}
  end

  def compound_list
    list = []
    list << self if compound?
    list |= od_content.to_a
    list |= compound_parent.decorate.compound_list if compound_parent
    list
  end

  private

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
    r.keys.map{|x| x.to_s.downcase}
  end

end
