require 'metadata/ingest/translators/form_to_attributes'
require 'metadata/ingest/translators/attributes_to_form'

# Base class for all-in-one form objects needed by templates and ingest forms
# to make the controller simpler - i.e., a facade class that wraps up all the
# weird translation magic and other irregularities.
class OregonDigital::Metadata::FormContainer
  # Checks validity of @asset and propogates errors up to @form if any exist
  def asset_valid?
    return true if @asset.valid?

    @asset.errors.each {|key, val| @form.errors.add(key, val)}
    return false
  end

  def new_record?
    !asset.persisted?
  end

  # Checks validity of @form
  def form_valid?
    return @form.valid?
  end

  # Returns the composite validity of the form and asset
  def valid?
    return form_valid? && asset_valid?
  end

  # Ensures form has at least one visible entry for each group
  def add_blank_groups
    for group in @form.groups
      if @form.send(group.pluralize).empty?
        @form.send("build_#{group}")
      end
    end
  end

  private

  # Creates an ingest form with map-based internal groups and our internal
  # association class
  def build_ingest_form
    @form = Metadata::Ingest::Form.new
    @form.internal_groups = @asset_map.keys.collect {|key| key.to_s}
    @form.association_class = OregonDigital::Metadata::Association
  end

  # Creates a new asset from the given id, if present, or from a template
  def build_asset(id, template_id)
    if id
      load_asset(id)
      return
    end

    @asset = @asset_class.new

    if template_id
      load_template(template_id)
      return
    end
  end

  def assign_form_attributes(params)
    attrs = params[:metadata_ingest_form]
    set_attributes(attrs) if attrs
  end

  # Loads the given asset and populates the form with its data
  def load_asset(id)
    @asset = @asset_class.find(id, cast: true)
    Metadata::Ingest::Translators::AttributesToForm.from(@asset).using_map(@asset_map).
        using_translator(OregonDigital::Metadata::AttributeTranslator).to(@form)
  end

  # Loads the given template and populates the form with its data, killing the
  # id value since template id isn't what we want there
  def load_template(id)
    template = Template.find(id)
    Metadata::Ingest::Translators::AttributesToForm.from(template).using_map(@template_map).
        using_translator(OregonDigital::Metadata::AttributeTranslator).to(@form)
    @form.id = nil
  end

  # Sets attributes on @form and pushes the data onto @asset if valid
  def set_attributes(attrs)
    attrs = attrs.to_hash
    @form.attributes = attrs
    if form_valid?
      OregonDigital::Metadata::FormToAttributes.from(@form).using_map(@asset_map).to(@asset)
    end
  end
end
