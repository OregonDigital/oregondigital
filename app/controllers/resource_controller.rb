class ResourceController < ApplicationController
  attr_reader :asset
  rescue_from ActiveFedora::ObjectNotFoundError, :with => :not_found
  before_filter :load_asset, :only => :show

  def show
    redirect_to catalog_path(:id => asset.pid), :status => 303
  end

  private

  def not_found
    raise ActionController::RoutingError.new('Resource not found.')
  end

  def load_asset
    @asset = ActiveFedora::Base.find(params[:id]).adapt_to_cmodel
  end
end
