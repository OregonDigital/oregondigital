class TemplatesController < FormControllerBase
  include Hydra::Controller::ControllerBehavior

  before_filter :setup_resources, only: [:new, :create, :edit, :update]
  before_filter :check_permissions

  def index
    @templates = Template.all_sorted
  end

  def new
    @form.add_blank_groups
  end

  def create
    validate_and_save("Created Template", :new)
  end

  def edit
    @form.add_blank_groups
  end

  def update
    validate_and_save("Updated Template", :edit)
  end

  def destroy
    template = Template.find(params[:id])
    title = template.title
    template.destroy
    redirect_to index_path, notice: "Deleted template '#{title}'"
  end

  private

  def check_permissions
    permission = case action_name
      when "edit", "update" then :update
      when "destroy"        then :delete
      else                       :create
    end

    unless can? permission, Template
      raise Hydra::AccessDenied.new "You do not have permission to #{permission} templates."
    end
  end

  # Sets up a form container for actions which use a form object
  def setup_resources
    if params[:metadata_ingest_form]
      template_name = params[:metadata_ingest_form].delete(:template_name)
    end

    defaults = {
      :asset_map => asset_map,
      :template_map => template_map,
      :asset_class => asset_class,
    }
    @form = OregonDigital::Metadata::TemplateFormContainer.new(params.merge(defaults))
    @form.asset.title = template_name if template_name
  end

  # Map for translating from asset to form.  All assets here are templates, so
  # we're just hard-coding the template map.
  def asset_map
    return TEMPLATE_MAP
  end

  # Map for translating from template to form.  I don't know if this will ever
  # need to change, but for now it's always the template map.
  def template_map
    return TEMPLATE_MAP
  end

  # Asset class used to instantiate a new object or load an existing one
  def asset_class
    return Template
  end

  # Path to template index
  def index_path
    return templates_path
  end

  # Saves the ingested asset, cloning associations and re-rendering the form
  # if cloned associations exist, otherwise redirecting to the index
  def validate_and_save(success_message, failure_template)
    unless @form.valid?
      render failure_template
      return
    end

    @form.save

    redirect_to index_path, :notice => success_message
  end
end
