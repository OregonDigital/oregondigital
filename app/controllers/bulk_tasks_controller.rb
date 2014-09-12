class BulkTasksController < ApplicationController
  before_filter :restrict_to_archivist
  
  def index
    BulkTask.refresh
    @tasks = BulkTask.all
  end

  def show
    @task = BulkTask.find(params[:id])
  end

  def ingest
    task = BulkTask.find(params[:id])
    task.ingest!
    redirect_to bulk_tasks_path, notice: "Added #{task.directory} to the ingest queue."
  end

  def reset_task
    task = BulkTask.find(params[:id])
    task.reset!
    redirect_to bulk_tasks_path, notice: "Reset job: #{task.directory}."
  end

  def review_all
    task = BulkTask.find(params[:id])
    task.queue_review
    task.save
    redirect_to bulk_tasks_path, notice: "Queued batch review of #{task.asset_ids.count} items from #{task.directory}."
  end

  def delete
    task = BulkTask.find(params[:id])
    task.queue_delete
    task.save
    redirect_to bulk_tasks_path, notice: "Queued batch delete of #{task.asset_ids.count} items from #{task.directory}."
  end

  private

    def restrict_to_archivist
      unless can? :review, GenericAsset
        raise Hydra::AccessDenied.new "You do not have permission to bulk ingest."
      end
    end
    
end
