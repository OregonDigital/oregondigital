class ThumbnailsController < ApplicationController

  def thumbnail_links
    redirect_to thumbnail_location(params[:id])
  end

  def thumbnail_location(pid)
    fd = OregonDigital::FileDistributor.new(pid)
    fd.base_path = thumbnail_base_path
    fd.extension = ".jpg"
    return fd.path
  end

  def thumbnail_base_path
    return "/media/thumbnails"
  end

end
