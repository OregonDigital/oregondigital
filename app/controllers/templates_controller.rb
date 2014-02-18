class TemplatesController < ApplicationController
  def index
    @templates = [GenericAsset.all.first, GenericAsset.all.last].collect do |asset|
      asset = asset.adapt_to(Template)
      asset.clear_relationship(:has_model)
      asset.assert_content_model
      asset
    end
  end
end
