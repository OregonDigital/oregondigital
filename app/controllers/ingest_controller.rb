require 'metadata/ingest/translators/form_to_attributes'

class IngestController < ApplicationController
  before_filter :setup_ingest_map

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

    # TODO: Replace this with something that dynamically sets up controlled vocabulary data
    # based on the form map and the datastream's properties
    @controlled_vocab_map = {
      "subject" => {
        "subject" => qa.search_path(:vocab => "Subject::QaLcsh", :q => "VOCABQUERY")
      }
    }
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
end
