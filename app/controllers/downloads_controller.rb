# Implements core Hydra download behaviors, allowing for arbitrary datastream downloading.  For
# more complex permissions or content download options, many methods in
# Hydra::Controller::DownloadBehavior can be overridden.
class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior

  # Redirect if appropriate
  def send_content(asset)
    decorated_asset = asset.decorate
    if decorated_asset.respond_to?(:derivative_redirects) && decorated_asset.derivative_redirects[datastream.dsid].present?
      redirect_to decorated_asset.derivative_redirects[datastream.dsid]
    else
      super
    end
  end

  def can_download?
    return super if datastream_to_show == default_content_ds
    return true if current_ability.can?(:create, asset.class)
    false
  end
end
