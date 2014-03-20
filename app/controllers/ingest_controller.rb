class IngestController < FormControllerBase
  include Hydra::Controller::ControllerBehavior

  before_filter :setup_resources, only: [:new, :create, :edit, :update]
  before_filter :check_permissions

  def index
    @templates = Template.all_sorted
  end

  def new
    @form.add_blank_groups
  end

  def edit
    @form.add_blank_groups
  end

  def create
    validate_and_save("Ingested new object", :new)
  end

  def update
    validate_and_save("Updated object", :edit)
  end

  private

  def check_permissions
    permission = :create
    if ["edit", "update"].include?(action_name)
      permission = :update
    end

    unless can? permission, GenericAsset
      raise Hydra::AccessDenied.new "You do not have permission to #{permission} assets."
    end
  end

  # Sets up a form container for actions which use a form object
  def setup_resources
    defaults = {
      :asset_map => asset_map,
      :template_map => template_map,
      :asset_class => asset_class,
      :cloneable => cloneable?
    }
    @form = OregonDigital::Metadata::FormContainer.new(params.merge(defaults))
  end

  # We allow cloning for new resources only
  def cloneable?
    return true if ["new", "create"].include?(action_name)
    return false
  end

  # Chooses the ingest map to be used for grouping form elements and
  # translating data.  This is hard-coded for now, but may eventually use
  # things like user groups or collection info or who knows what.
  def asset_map
    return INGEST_MAP
  end

  # Map for translating from template to form.  I don't know if this will ever
  # need to change, but for now it's always the template map.
  def template_map
    return TEMPLATE_MAP
  end

  # Asset class used to instantiate a new object or load an existing one
  def asset_class
    return GenericAsset
  end

  # Path to ingest index
  def index_path
    return ingest_index_path
  end
end
