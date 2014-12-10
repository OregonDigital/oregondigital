class AssetUndeleter
  # Undeletes an asset with a given pid
  def self.call(asset, callbacks=[])
    new(asset, callbacks).perform
  end

  attr_accessor :asset, :callbacks
  def initialize(asset, callbacks)
    @asset = asset
    @callbacks = Array.wrap(callbacks)
  end

  def perform
    asset.undelete!
    notify_callbacks
  end

  private

  def notify_callbacks
    callbacks.each do |callback|
      callback.success(asset)
    end
  end

end
