# Subclasses the common form container behaviors, implementing behavior specific to
# ingesting a digital object:
#
# - Handling of uploaded files
# - Handling of cloned fields for ingest-and-clone processes
# - Determining if an ingested object has raw RDF statements not yet mapped to a
#   form field
class OregonDigital::Metadata::IngestFormContainer < OregonDigital::Metadata::FormContainer
  attr_reader :asset, :form, :upload, :raw_statements, :cloneable

  def initialize(params = {})
    @asset_map = params.delete(:asset_map)
    @template_map = params.delete(:template_map)
    @asset_class = params.delete(:asset_class)
    @cloneable = params.delete(:cloneable)
    raise "Translation map must be specified" unless @asset_map

    prepare_data(params)
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

  # Returns true if this was a cloneable form and any of @form's associations
  # were marked cloned
  def has_cloned_associations?
    return false if !@cloneable

    for assoc in @form.associations
      return true if assoc.clone
    end

    return false
  end

  # Returns a new FormContainer with an ingest form containing all associations
  # marked for cloning
  def clone_associations
    new_form = OregonDigital::Metadata::IngestFormContainer.new(
      :asset_map => @asset_map,
      :template_map => @template_map,
      :asset_class => @asset_class,
      :cloneable => true
    )
    for assoc in @form.associations.select {|assoc| assoc.clone == true}
      new_form.form.add_association(assoc) if assoc.clone
    end

    new_form.add_blank_groups

    return new_form
  end

  private

  # Sets up all internal objects based on parameters
  def prepare_data(params)
    build_ingest_form
    build_uploader(params[:upload], params[:upload_cache])
    build_asset(params[:id], params[:template_id])
    assign_form_attributes(params)
    find_unmapped_rdf
  end

  # Overrides ingest form creation to use the cloneable association class if
  # this container allows cloning fields
  def build_ingest_form
    super
    @form.association_class = OregonDigital::Metadata::CloneableAssociation if @cloneable
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

  def find_unmapped_rdf
    @raw_statements = RDF::Graph.new
    mapped_predicates = []

    # Iterate over the asset map and inspect each delegated attribute, building
    # a list of raw predicates we've mapped to the form
    for group, type_maps in @asset_map
      for type, attr_definition in type_maps
        object, attribute = extract_delegation_data(attr_definition)
        mapped_predicates << object.class.properties[attribute]["predicate"]
      end
    end

    asset_subject = @asset.descMetadata.rdf_subject
    for statement in @asset.descMetadata.graph
      is_mapped = mapped_predicates.include?(statement.predicate)
      is_same_subject = statement.subject == asset_subject
      @raw_statements << statement unless is_mapped && is_same_subject
    end
  end

  def extract_delegation_data(attr_definition)
    objects = attr_definition.to_s.split(".")
    attribute = objects.pop
    object = objects.reduce(@asset, :send)
    return [object, attribute]
  end
end
