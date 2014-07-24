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
    task.enqueue
    redirect_to bulk_tasks_path, notice: "Added #{task.directory} to the ingest queue."
  end

  def reset_task
    task = BulkTask.find(params[:id])
    task.reset
    redirect_to bulk_tasks_path, notice: "Reset #{task.directory}."
  end

  def review_all
    task = BulkTask.find(params[:id])
    task.status = :processing
    task.save
    # task.review_assets
    Resque.enqueue(BulkReviewJob, task.id)
    redirect_to bulk_tasks_path, notice: "Batch reviewed #{task.asset_ids.count} items from #{task.directory}."
  end

  def delete_all
    task = BulkTask.find(params[:id])
    task.status = :processing
    task.save
    # task.delete_assets
    Resque.enqueue(BulkDeleteJob, task.id)
    redirect_to bulk_tasks_path, notice: "Batch deleted #{task.asset_ids.count} items from #{task.directory}."
  end

  private

    def restrict_to_archivist
      unless can? :review, GenericAsset
        raise Hydra::AccessDenied.new "You do not have permission to bulk ingest."
      end
    end
    
end
