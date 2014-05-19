class DocumentController < ApplicationController
  respond_to :json

  def show
    respond_with DocumentMetadataGenerator.call(document)
  end


  private

  def document
    @document ||= Document.find(params[:id]).decorate
  end
end
