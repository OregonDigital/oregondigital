require 'metadata/ingest/translators/form_to_attributes'
require 'metadata/ingest/translators/attributes_to_form'

class IngestController < ApplicationController
  before_filter :build_controlled_vocabulary_map
  before_filter :setup_resources, only: [:new, :create, :edit, :update]
  before_filter :process_upload, only: [:create, :update]
  before_filter :load_asset, only: [:edit, :update]
  before_filter :add_blank_groups, only: [:new, :edit]
  before_filter :form_to_asset, only: [:create, :update]

  def index
  end

  def new
  end

  def edit
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

  # This must be a very early filter: if there was an upload, we have to store
  # variables in case the form is re-rendered
  def process_upload
    @has_upload = params[:upload] || params[:upload_cache]

    if @has_upload
      @upload.file = params[:upload]
      @upload.file_cache = params[:upload_cache]
    end
  end

  # Attempts to save the asset, merging errors with the ingest form since the
  # form elements aren't mapped 1:1 to the asset fields. (type + value +
  # internal represent a single property).
  #
  # Note that fedora object errors won't necessarily make sense to the form if
  # they're too low-level, so custom validations should be carefully worded.
  def validate_and_save(success_message, failure_template)
    unless @form.valid?
      render failure_template
      return
    end

    unless @asset.valid?
      @asset.errors.each {|key, val| @form.errors.add(key, val)}
      render failure_template
      return
    end

    save_asset
    redirect_to ingest_index_path, :notice => success_message
  end

  # Stores uploaded file on @asset, attempts to save it, and returns success
  #
  # TODO: Move this into a service or something - the magic here will likely be
  # needed on bulk ingest, too
  def save_asset
    if @has_upload
      # If we don't explicitly process the file, its content type can be all messed up
      @upload.file.process!

      # Set data on the asset's content datastream
      mimetype = @upload.file.file.content_type
      @asset.content.content = @upload.file.read
      @asset.content.dsLabel = @upload.file.filename
      @asset.content.mimeType = mimetype
    end

    @asset.save
  end

  # Ensures page has at least one visible entry for each group
  def add_blank_groups
    for group in @form.groups
      if @form.send(group.pluralize).empty?
        @form.send("build_#{group}")
      end
    end
  end

  # Sets up @form and @asset for new and edit forms
  def setup_resources
    @form = Metadata::Ingest::Form.new
    @form.internal_groups = ingest_map.keys.collect {|key| key.to_s}
    @asset = GenericAsset.new
    @upload = IngestFileUpload.new
  end

  # Loads @asset from Fedora and uses the translator to get the asset's
  # attributes onto @form
  def load_asset
    @asset = GenericAsset.find(params[:id])
    Metadata::Ingest::Translators::AttributesToForm.from(@asset).using_map(ingest_map).to(@form)
  end

  # Stores parameters on @form and translates those to @asset attributes
  def form_to_asset
    @form.attributes = params[:metadata_ingest_form].to_hash
    if @form.valid?
      Metadata::Ingest::Translators::FormToAttributes.from(@form).using_map(ingest_map).to(@asset)
    end
  end

  # Iterates over the ingest map, and looks up properties in the datastream
  # definition to see where we need controlled vocab and what the URL will be
  def build_controlled_vocabulary_map
    @controlled_vocab_map = {}

    for group, type_map in ingest_map
      @controlled_vocab_map[group.to_s] = {}
      for type, attribute in type_map
        # We are assuming that a new-style datastream is going to be the final
        # object in the type-to-attribute value (i.e., in "foo.bar.baz", bar is
        # datastream, baz is attribute).  With this assumption we can pull the
        # property definition to see if a class is registered, and if so,
        # figure out how to set up a controlled vocabulary query URI.
        objects = attribute.to_s.split(".")
        attribute = objects.pop
        property = objects.reduce(GenericAsset.new, :send).class.properties[attribute]

        # TODO: What does it mean if we have no property for a mapped
        # attribute?  Likely a misconfiguration that the user cannot control.
        # We should send an error report somewhere here and silently move on,
        # as a browser error isn't going to be particularly useful :-/
        unless property
          raise "Invalid attribute while building controlled vocabulary map: group => " +
                "#{group.inspect}, type => #{type.inspect}, attribute => #{attribute.inspect}"
        end

        # Without a class, the data is simple and not something we try to
        # translate in any way
        next unless property[:class_name]

        # This is ugly - maybe we should have something more directly exposing the QA-friendly vocab parameter
        # (or create a map of param-to-class that each controlled vocab class registers and exposes)
        qa_class = property[:class_name].qa_interface.class
        vocab_param = qa_class.to_s.sub(/^OregonDigital::ControlledVocabularies::/, "")
        next if vocab_param.blank?

        path = qa.search_path(:vocab => vocab_param, :q => "VOCABQUERY")
        @controlled_vocab_map[group.to_s][type.to_s] = path
      end
    end
  end
end
