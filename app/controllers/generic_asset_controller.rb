class GenericAssetController < ApplicationController
  include Hydra::Controller::ControllerBehavior
  load_and_authorize_resource

  def review
    authorize! :review, @generic_asset
    @generic_asset.review!
    flash[:notice] = "Successfully reviewed."
    redirect_to reviewer_path
  end

end