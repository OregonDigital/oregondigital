class IngestController < FormControllerBase
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

  # Chooses the ingest map to be used for grouping form elements and
  # translating data.  This is hard-coded for now, but may eventually use
  # things like user groups or collection info or who knows what.
  def ingest_map
    return INGEST_MAP
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
