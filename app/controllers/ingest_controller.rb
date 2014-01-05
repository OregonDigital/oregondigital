require 'metadata/ingest/translators/form_to_attributes'

class IngestController < ApplicationController
  before_filter :setup_ingest_map
  before_filter :build_controlled_vocabulary_map

  def index
  end

  # Combined new/edit form handler
  def form
    @form = Metadata::Ingest::Form.new

    for group in Metadata::Ingest::Form.groups
      if @form.send(group.pluralize).empty?
        @form.send("build_#{group}")
      end
    end
  end

  # Combined create/update form handler
  def save
    @form = Metadata::Ingest::Form.new(params[:metadata_ingest_form].to_hash)
    @asset = GenericAsset.new
    Metadata::Ingest::Translators::FormToAttributes.from(@form).to(@asset)
    @asset.save

    redirect_to :ingest
  end

  private

  # Chooses the ingest map to be used for grouping form elements and
  # translating data.  This is hard-coded for now, but may eventually use
  # things like user groups or collection info or who knows what.
  def ingest_map
    return INGEST_MAP
  end

  # Sets up the form to use the chosen ingest map
  def setup_ingest_map
    Metadata::Ingest::Form.internal_groups = ingest_map.keys.collect {|key| key.to_s}
    Metadata::Ingest::Translators::FormToAttributes.map = ingest_map
  end

  # Iterates over the ingest map, and looks up properties in the datastream
  # definition to see where we need controlled vocab and what the URL will be
  def build_controlled_vocabulary_map
    @controlled_vocab_map = {}

    for group, type_map in ingest_map
      @controlled_vocab_map[group.to_s] = {}
      for type, attribute in type_map
        property = Datastream::OregonRDF.properties[attribute]

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
