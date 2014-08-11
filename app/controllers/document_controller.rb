class DocumentController < ApplicationController
  respond_to :json

  def show
    respond_with DocumentMetadataGenerator.call(document)
  end

  def fulltext
    render :json => full_text_result(params[:q]), :callback => params[:callback]
  end


  private

  def full_text_result(query)
    OregonDigital::OCR::BookreaderSearchGenerator.call(document, query)
  end

  def document
    @document ||= Document.find(params[:id]).decorate
  end
end
