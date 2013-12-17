class IngestController < ApplicationController
  def index
  end

  def form
    @form = Metadata::Ingest::Form.new

    for group in Metadata::Ingest::Form.groups
      if @form.send(group.pluralize).empty?
        @form.send("build_#{group}")
      end
    end
  end
end
