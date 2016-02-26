# View-specific logic for the solr documents that the CatalogController creates
class BulkTaskDecorator < Draper::Decorator
  delegate_all

  def task_buttons
    {
      "Ingest" => {
        :requirement => ingestible?,
        :path => h.ingest_bulk_task_path(id)
      },
      "Refresh" => {
        :requirement => true,
        :path => h.refresh_bulk_task_path(id)
      },
      "Review All" => {
        :requirement => ingested? && !reviewed?,
        :path => h.review_all_bulk_task_path(id)
      },
      "Delete All" => {
        :requirement => ingested? && !reviewed?,
        :path => h.delete_bulk_task_path(id),
        :method => "delete",
        :class => "danger"
      },
      "Retry Ingest" => {
        :requirement => errored? && error_states == ["ingesting"],
        :path => h.ingest_bulk_task_path(id)
      },
      "Retry Review" => {
        :requirement => errored? && error_states == ["reviewing"],
        :path => h.review_all_bulk_task_path(id),
        :notify => "Are you sure you want to review all items?"
      },
      "Retry Delete" => {
        :requirement => errored? && error_states == ["deleting"],
        :path => h.delete_bulk_task_path(id),
        :method => "delete",
        :class => "danger",
        :notify => "Are you sure you want to delete all items?"
      },
      "Reset" => {
        :requirement => true,
        :path => h.reset_bulk_task_path(id),
        :method => "delete",
        :class => "danger",
        :notify => "Are you sure you want to reset? This will lose all state and information about this bulk task."
      },
      "Stop Ingest" => {
        :requirement => children_statuses.include?("ingesting"),
        :path => h.stop_ingest_bulk_task_path(id),
        :method => "delete",
        :class => "danger",
        :notify => "Are you sure you want to stop the ingest?"
      }
    }
  end
end
