class TemplatesController < FormControllerBase
  include Hydra::Controller::ControllerBehavior
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

  # Overrides base behavior to handle the magic template varible (title) which
  # goes directly onto the template object, not the form object
  def setup_resources
    if params[:metadata_ingest_form]
      template_name = params[:metadata_ingest_form].delete(:template_name)
    end

    super

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
end
