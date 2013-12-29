require 'metadata/ingest/translators/form_to_attributes'

class IngestController < ApplicationController
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
    Metadata::Ingest::Translators::FormToAttributes.map = INGEST_MAP
    Metadata::Ingest::Translators::FormToAttributes.from(@form).to(@asset)
    @asset.save

    redirect_to :ingest
  end
end
