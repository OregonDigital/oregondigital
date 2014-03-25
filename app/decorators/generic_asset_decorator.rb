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
    return false if field_value(field).blank?
    true
  end

  def field_label(field)
    I18n.t("oregondigital.catalog.show.#{field.downcase}", :default => field.humanize)
  end

  def field_value(field)
    results = resource.get_values(field)
    results = results.map { |r| field_value_to_string(r) }
    results.join(", ")
  end

  private

  def field_value_to_string(value)
    value = value.resource if value.respond_to?(:resource)
    return value.to_s unless value.respond_to?(:rdf_label)
    return "" if value.rdf_label.first.to_s == value.rdf_subject

    return value.rdf_label.first.to_s
  end

  def property_keys
    r = resource.send(:properties).keys
  end

  def configured_show_keys
    r = I18n.t("oregondigital.catalog.show")
    r = {} unless r.kind_of?(Hash)
    r.keys.map{|x| x.to_s.downcase}
  end

end
