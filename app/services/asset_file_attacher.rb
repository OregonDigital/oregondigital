# Handles file attachments and transmogrification of assets based on said file
# attachments.
#
# The file taken in the initializer *must* be an instance of the IngestUploader
# class.  This ensures we get all the mimetype magic and any other processing
# Carrierwave offers.  Using this service outside the web world (bulk ingest)
# is easy, as a Carrierwave "uploader" isn't as inflexible as it sounds.
#
# After initializing an instance, call `process` to set up the asset's content
# datastream, and REPLACE your asset with the return from
# `AssetFileAttacher#asset`!  This is VERY important.  The mime type of the
# file determines the class of the asset, but Ruby doesn't have actual casting,
# so the "cast" is done by returning a new object with the same data.
class AssetFileAttacher
  attr_reader :asset

  def initialize(asset, file)
    @asset = asset
    @file = file
    @upload_processed = false
  end

  # Creates an AssetFileAttacher, attaches the file to the asset, and returns
  # the modified asset
  def self.call(asset, file)
    afa = self.new(asset, file)
    afa.attach_file_to_asset
    return afa.asset
  end

  # Sets file data on asset's content datastream and replaces @asset base on
  # the file's mimetype
  def attach_file_to_asset
    process_upload
    @asset.content.content = @file.file.read
    @asset.content.dsLabel = @file.file.filename
    @asset.content.mimeType = mimetype
    set_asset_class
  end

  private

  # This runs carrierwave's mimetype detection (and any other magic defined in
  # the uploader class)
  def process_upload
    return if @upload_processed
    @file.file.process!
    @upload_processed = true
  end

  # Gets the mime type of the asset's file
  def mimetype
    process_upload
    return @file.file.file.content_type
  end

  # Returns our standard lookup.  Consider making this a DB pull or something if we find we need
  # to configure classes without deploying new code.
  def asset_class_lookup
    return ASSET_CLASS_LOOKUP
  end

  # Determines asset class based on file's mimetype
  def set_asset_class
    for pattern, klass in asset_class_lookup
      if pattern === mimetype
        new_klass = klass
      end
    end

    transmogrify_asset(new_klass || GenericAsset)
  end

  # Replaces @asset with an identical object of the given class
  def transmogrify_asset(klass)
    return if @asset.class == klass

    @asset = @asset.adapt_to(klass)
    @asset.clear_relationship(:has_model)
    @asset.assert_content_model
  end
end
