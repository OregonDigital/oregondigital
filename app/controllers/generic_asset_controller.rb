class GenericAssetController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  load_and_authorize_resource
  before_filter :adapt_asset

  def review
    authorize! :review, @generic_asset
    @generic_asset.review!
    flash[:notice] = "Successfully reviewed."
    redirect_to reviewer_path
  end

  def destroy
    authorize! :destroy, @generic_asset
    @generic_asset.soft_destroy
    flash[:notice] = I18n.t("oregondigital.generic_asset.destroy")
    redirect_to catalog_path
  end

  def adapt_asset
    @generic_asset = @generic_asset.adapt_to_cmodel if @generic_asset
  end

end
