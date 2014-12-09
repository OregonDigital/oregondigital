class GenericAssetController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  load_and_authorize_resource

  def review
    authorize! :review, asset
    asset.review!
    flash[:notice] = "Successfully reviewed."
    redirect_to reviewer_path
  end

  def destroy
    authorize! :destroy, asset
    asset.soft_destroy
    flash[:notice] = I18n.t("oregondigital.generic_asset.destroy")
    redirect_to catalog_path
  end

  private
  
  def asset
    @asset ||= AssetAdapter.call(@generic_asset)
  end

  class AssetAdapter
    def self.call(asset)
      return asset unless asset.respond_to?(:adapt_to_cmodel)
      asset.adapt_to_cmodel
    end
  end

end
