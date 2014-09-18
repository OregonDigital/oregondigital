class BulkTask < ActiveRecord::Base

  validates_presence_of :directory
  validates :status, inclusion: { in: %w(new ingesting errored ingested reviewing reviewed deleting deleted), message: "%{value} is not a valid status" }

  delegate :new?, :ingesting?, :errored?, :ingested?, :reviewed?, :reviewing?, :deleting?, :deleted?, :to => :status

  has_many :bulk_task_children, :dependent => :destroy

  before_create :generate_children
  after_initialize :update_status

  def self.refresh
    (disk_bulk_folders - relative_db_bulk_folders).each do |dir|
      BulkTask.new(:directory => dir).save
    end
  end

  def self.disk_bulk_folders
    Dir.glob(File.join(APP_CONFIG.batch_dir, '*')).select { |f| File.directory? f }.map{|x| Pathname.new(x).basename.to_s}
  end

  def self.relative_db_bulk_folders
    BulkTask.pluck(:directory).map{|x| Pathname.new(x).basename.to_s}
  end

  def refresh
    generate_bag_children
  end

  def status
    ActiveSupport::StringInquirer.new(attributes['status'])
  end

  def ingestible?
    new? || children_statuses.include?("pending")
  end

  def type
    @type ||= :csv unless Dir.glob(File.join(absolute_path, '*.csv')).empty?
    @type ||= :bag
  end

  def absolute_path
    Pathname(directory).absolute? ? directory : File.join(APP_CONFIG.batch_dir, directory)
  end

  def ingest!
    return if bulk_task_children.length == 0
    bulk_task_children.each do |child|
      child.queue_ingest! unless child.ingesting? || child.ingested? || child.reviewed? || child.reviewing?
    end
    self.status = "ingesting"
    save
  end

  def delete_all!
    return if bulk_task_children.length == 0
    bulk_task_children.each do |child|
      child.queue_delete! unless child.ingested_pid.blank?
    end
    self.status = "deleting"
    save
  end

  def review!
    return if bulk_task_children.length == 0
    bulk_task_children.each do |child|
      child.queue_review! if child.ingested? || (child.errored? && child.error_state == "reviewing")
    end
    self.status = "reviewing"
    save
  end

  def assets
    @assets ||= bulk_task_children.map(&:asset).compact
  end

  def asset_ids
    @asset_ids ||= bulk_task_children.pluck(:ingested_pid)
  end

  def error_states
    @error_states ||= bulk_task_children.map(&:error_state).compact.uniq
  end

  private

  def children_statuses
    @children_statuses ||= bulk_task_children.pluck(:status).uniq
  end

  def update_status
    if bulk_task_children.count > 0
      if children_statuses.include?("errored")
        self.status = "errored"
      elsif children_statuses == ["ingested"] && !reviewed?
        self.status = "ingested"
      elsif children_statuses == ["reviewed"]
        self.status = "reviewed"
      elsif children_statuses.sort == ["ingested", "reviewed"]
        self.status = "ingested"
      elsif children_statuses == ["deleted"]
        self.status = "deleted"
      end
    end
  end

  def generate_children
    send("generate_#{type}_children")
  end

  def bag_directories
    Hybag::BulkIngester.new(absolute_path).map{|ingester| ingester.bag.bag_dir}
  end

  def child_directories
    bulk_task_children.pluck(:target)
  end

  def generate_bag_children
    (bag_directories - child_directories).each do |directory|
      bulk_task_children << BulkTaskChild.new(:target => directory)
    end
  end

end
