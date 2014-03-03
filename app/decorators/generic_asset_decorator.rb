# View-specific logic for the solr documents that the CatalogController creates
class GenericAssetDecorator < Draper::Decorator
  delegate_all

  # Figures out how this asset needs to be viewed when rendered by itself (i.e., probably won't
  # want to use this on the search index)
  def view_partial
    "generic_viewer"
  end

  def sorted_show_fields
    (configured_show_keys | resource.send(:properties).keys).select{|x| display_field?(x)}
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
    results.map do |r|
      if r.respond_to?(:rdf_label)
        r.rdf_label.to_s
      else
        r.to_s
      end
    end
    results.join(", ")
  end

  private

  def property_keys
    resource.send(:properties).keys.map{|x| x.to_s.downcase}
  end

  def configured_show_keys
    r = I18n.t("oregondigital.catalog.show")
    r = {} unless r.kind_of?(Hash)
    r.keys.map{|x| x.to_s.downcase}
  end

end
