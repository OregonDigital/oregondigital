module FacetPatch
  def label
    result = super
    return controlled_label(result) if result.to_s.include?("filler$")
    return result
  end

  def controlled_label(key)
    key = key.gsub("filler$","")
    I18n.t("oregondigital.catalog.facet.#{key}", :default => key.humanize)
  end
end

Blacklight::Configuration::FacetField.send(:include, FacetPatch)
