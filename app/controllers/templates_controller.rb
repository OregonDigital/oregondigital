class TemplatesController < FormControllerBase
  def index
    @templates = [GenericAsset.all.first, GenericAsset.all.last].collect do |asset|
      asset = asset.adapt_to(Template)
      asset.clear_relationship(:has_model)
      asset.assert_content_model
      asset
    end
  end

  def new
    @form.add_blank_groups
  end

  private

  # Chooses the ingest map to be used for grouping form elements and
  # translating data.  This is hard-coded for now, but may eventually use
  # things like user groups or collection info or who knows what.
  def ingest_map
    return INGEST_MAP
  end

  # Asset class used to instantiate a new object or load an existing one
  def asset_class
    return Template
  end
end
