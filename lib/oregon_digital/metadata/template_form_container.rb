# Subclasses the common form container behaviors, implementing behavior
# specific to creating ingest templates - currently just the partial
# validations we need on the ingest form object
class OregonDigital::Metadata::TemplateFormContainer < OregonDigital::Metadata::FormContainer
  attr_reader :asset, :form

  def initialize(params = {})
    @asset_map = params.delete(:asset_map)
    @template_map = params.delete(:template_map)
    @asset_class = params.delete(:asset_class)
    raise "Translation map must be specified" unless @asset_map

    prepare_data(params)
  end

  # Stores the template asset in AF
  def save
    @asset.save
  end

  private

  # Sets up all internal objects based on parameters
  def prepare_data(params)
    build_ingest_form
    build_asset(params[:id], params[:template_id])
    assign_form_attributes(params)
  end
end
