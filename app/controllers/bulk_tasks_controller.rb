class BulkTasksController < ApplicationController
  before_filter :restrict_to_archivist
  before_filter :find_task, :except => [:index, :all_tasks]
  
  def index
    BulkTask.refresh
    @tasks = BulkTaskDecorator.decorate_collection(BulkTask.includes(:bulk_task_children).last(30))
  end

  def all_tasks
    BulkTask.refresh
    @tasks = BulkTask.includes(:bulk_task_children).all.decorate
  end

  def show
  end

  def ingest
    @task.ingest!
    redirect_to bulk_tasks_path, notice: "Added #{@task.directory} to the ingest queue."
  end

  def reset
    @task.destroy
    redirect_to bulk_tasks_path, :notice => "Reset #{@task.directory}."
  end

  def stop_ingest
    jobs = Resque.peek("ingest", 0, 100000).select{|x| x["class"] == "BulkIngest::IngestChild"}
    job_ids = jobs.map{|x| x["args"].first}
    @task.bulk_task_children.each do |child|
      next unless job_ids.include?(child.id)
      child.status = "pending"
      child.save
      Resque::Job.destroy("ingest", "BulkIngest::IngestChild", child.id)
    end
    @task.status = "new"
    @task.save
    redirect_to bulk_tasks_path, :notice => "Stopped ingest of #{@task.directory}."
  end

  def refresh
    @task.refresh
    redirect_to bulk_tasks_path, :notice => "Refreshed children for #{@task.directory}"
  end

  def reset_task
    @task.reset!
    redirect_to bulk_tasks_path, notice: "Reset job: #{@task.directory}."
  end

  def review_all
    @task.review!
    redirect_to bulk_tasks_path, notice: "Queued batch review of #{@task.asset_ids.count} items from #{@task.directory}."
  end

  def delete
    @task.delete_all!
    redirect_to bulk_tasks_path, notice: "Queued batch delete of #{@task.asset_ids.count} items from #{@task.directory}."
  end

  private

  def find_task
    @task = BulkTask.find(params[:id]).decorate
  end

    def restrict_to_archivist
      unless can? :review, GenericAsset
        raise Hydra::AccessDenied.new "You do not have permission to bulk ingest."
      end
    end
    
end
