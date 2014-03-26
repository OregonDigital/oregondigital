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

  # Overrides the default form validity check to only flag associations that
  # have no type - having no value is okay on templates
  #
  # FIXME: This is a very hacky solution - long-term I'd like to get a form
  # that has various validations compartmentalized.  For now, however, that
  # would require significant changes to the form metadata gem.
  def form_valid?
    # If the form is completely valid, all's well
    return true if @form.valid?

    # No dice?  Go through errors looking specifically for the errors that we
    # don't consider problematic
    for field, error in @form.errors.dup
      if field.to_s =~ /\.value/ && error =~ /blank/i
        @form.errors.delete(field)
      end
    end

    for association in @form.associations
      for field, error in association.errors.dup
        if field == :value && error =~ /blank/i
          association.errors.delete(:value)
        end
      end
    end

    return @form.errors.empty?
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
