module FacetPatch
  ##
  # Patches facets to replace filler values with I18n.
  # This is required because I18n isn't available when CatalogController is first read in, so we have to lazy-evaluate.
  def label
    result = super
    return controlled_label(result) if result.to_s.include?("filler$")
    return result
  end

  def controlled_label(key)
    key = key.gsub("filler$","")
    I18n.t("oregondigital.catalog.facet.#{key}", :default => OregonDigital::Metadata::FieldTypeLabel.for(key))
  end
end

Blacklight::Configuration::FacetField.send(:include, FacetPatch)
