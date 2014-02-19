require 'metadata/ingest/translators/form_to_attributes'
require 'metadata/ingest/translators/attributes_to_form'

# All-in-one form object for managing our forms and their translations while making it seem like
# a more standard single-object-as-model approach
class OregonDigital::Metadata::FormContainer
  attr_reader :asset, :form, :upload

  def initialize(params = {})
    @translation_map = params.delete(:map)
    @asset_class = params.delete(:asset_class)
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
    if has_upload?
      @asset = Ingest::AssetFileAttacher.call(@asset, @upload)
    end

    @asset.save
  end

  private

  # Sets up all internal objects based on parameters
  def prepare_data(params)
    build_ingest_form
    build_uploader(params[:upload], params[:upload_cache])
    build_asset(params[:id], params[:template_id])
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

  def build_asset(id, template_id)
    if id
      load_asset(id)
      return
    end

    if template_id
      load_template(template_id)
      return
    end

    @asset = @asset_class.new
  end

  def assign_form_attributes(params)
    attrs = params[:metadata_ingest_form]
    set_attributes(attrs) if attrs
  end

  # Loads the given asset and populates the form with its data
  def load_asset(id)
    @asset = @asset_class.find(id, cast: true)
    Metadata::Ingest::Translators::AttributesToForm.from(@asset).using_map(@translation_map).
        using_translator(OregonDigital::Metadata::AttributeTranslator).to(@form)
  end

  # Loads the given template and populates the form with its data, killing the
  # id value since template id isn't what we want there
  def load_template(id)
    template = Template.find(id)
    Metadata::Ingest::Translators::AttributesToForm.from(template).using_map(@translation_map).
        using_translator(OregonDigital::Metadata::AttributeTranslator).to(@form)
    @form.id = nil
  end

  # Sets attributes on @form and pushes the data onto @asset if valid
  def set_attributes(attrs)
    attrs = attrs.to_hash
    @form.attributes = attrs
    if @form.valid?
      OregonDigital::Metadata::FormToAttributes.from(@form).using_map(@translation_map).to(@asset)
    end
  end
end
