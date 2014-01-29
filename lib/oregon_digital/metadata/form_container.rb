# All-in-one form object for managing our forms and their translations while making it seem like
# a more standard single-object-as-model approach
class OregonDigital::Metadata::FormContainer
  attr_reader :asset, :form, :upload

  def initialize(params = {})
    @translation_map = params.delete(:map)
    raise "Translation map must be specified" unless @translation_map

    prepare_data(params)
  end

  # Returns the composite validity of the form and the asset
  def valid?
    return true if @form.valid? && @asset.valid?
    return false unless @form.valid?

    # If the asset is invalid, we need to copy up all the errors
    @asset.errors.each {|key, val| @form.errors.add(key, val)}
    return false
  end

  # Ensures form has at least one visible entry for each group
  def add_blank_groups
    for group in @form.groups
      if @form.send(group.pluralize).empty?
        @form.send("build_#{group}")
      end
    end
  end

  def has_upload?
    return @has_upload
  end

  # Stores the asset with any uploaded file attached
  def save
    process_upload if has_upload?
    @asset.save
  end

  private

  # Sets up all internal objects based on parameters
  def prepare_data(params)
    build_ingest_form
    build_uploader(params[:upload], params[:upload_cache])
    build_asset(params[:id])
    assign_form_attributes(params)
  end

  def build_ingest_form
    @form = Metadata::Ingest::Form.new
    @form.internal_groups = @translation_map.keys.collect {|key| key.to_s}
  end

  def build_uploader(upload, upload_cache)
    @upload = IngestFileUpload.new
    @has_upload = false

    if upload || upload_cache
      @has_upload = true
      @upload.file = upload
      @upload.file_cache = upload_cache
    end
  end

  def build_asset(id = nil)
    load_asset(id) if id
    @asset ||= GenericAsset.new
  end

  def assign_form_attributes(params)
    attrs = params[:metadata_ingest_form]
    set_attributes(attrs) if attrs
  end

  # Loads the given asset and populates the form with its data
  def load_asset(id)
    @asset = GenericAsset.find(id)
    Metadata::Ingest::Translators::AttributesToForm.from(@asset).using_map(@translation_map).
        using_translator(OregonDigital::Metadata::AttributeTranslator).to(@form)
  end

  # Sets attributes on @form and pushes the data onto @asset if valid
  def set_attributes(attrs)
    attrs = attrs.to_hash
    @form.attributes = attrs
    if @form.valid?
      Metadata::Ingest::Translators::FormToAttributes.from(@form).using_map(@translation_map).to(@asset)
    end
  end

  # Sets up content datastream on asset with uploaded file
  #
  # TODO: Move this into a service or something - the magic here will likely be
  # needed on bulk ingest, too
  def process_upload
    # If we don't explicitly process the file, its content type can be all messed up
    @upload.file.process!

    # Set data on the asset's content datastream
    mimetype = @upload.file.file.content_type
    @asset.content.content = @upload.file.read
    @asset.content.dsLabel = @upload.file.filename
    @asset.content.mimeType = mimetype
  end
end
