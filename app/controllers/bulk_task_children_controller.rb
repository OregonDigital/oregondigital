class BulkTaskChildrenController < ApplicationController
  def show
    @child = BulkTaskChild.find(params[:id])
  end
end
