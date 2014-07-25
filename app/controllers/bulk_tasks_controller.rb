class BulkTasksController < ApplicationController
  before_filter :restrict_to_archivist
  
  def index
    restrict_to_archivist
    BulkTask.refresh
    @tasks = BulkTask.all
  end

  def show
    restrict_to_archivist
    @task = BulkTask.find(params[:id])
  end

  def ingest
    restrict_to_archivist
    task = BulkTask.find(params[:id])
    task.enqueue
    redirect_to bulk_tasks_path, notice: "Added #{task.directory} to the ingest queue."
  end

  def reset_task
    restrict_to_archivist
    task = BulkTask.find(params[:id])
    task.reset!
    redirect_to bulk_tasks_path, notice: "Reset job: #{task.directory}."
  end

  def review_all
    restrict_to_archivist
    task = BulkTask.find(params[:id])
    task.queue_review
    redirect_to bulk_tasks_path, notice: "Queued batch review of #{task.asset_ids.count} items from #{task.directory}."
  end

  def delete_all
    restrict_to_archivist
    task = BulkTask.find(params[:id])
    task.queue_delete
    redirect_to bulk_tasks_path, notice: "Queued batch delete of #{task.asset_ids.count} items from #{task.directory}."
  end

  private

    def restrict_to_archivist
      unless can? :review, GenericAsset
        raise Hydra::AccessDenied.new "You do not have permission to bulk ingest."
      end
    end
    
end
