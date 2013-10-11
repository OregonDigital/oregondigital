# Implements core Hydra download behaviors, allowing for arbitrary datastream downloading.  For
# more complex permissions or content download options, many methods in
# Hydra::Controller::DownloadBehavior can be overridden.
class DownloadsController < ApplicationController
  include Hydra::Controller::DownloadBehavior
end
