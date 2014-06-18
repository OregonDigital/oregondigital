class GenericAsset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Workflow
  include OregonDigital::OAI::Concern
  include ActiveFedora::Rdf::Identifiable
  extend OregonDigital::CsvBulkIngestible
  extend OregonDigital::BagIngestible


  has_metadata :name => 'descMetadata', :type => Datastream::OregonRDF
  has_metadata :name => 'rightsMetadata', :type =>
    Datastream::RightsMetadata

  has_file_datastream name: 'content', type: Datastream::Content

  before_save :check_derivatives
  after_save :queue_derivatives
  attr_accessor :skip_queue
  after_save :queue_fetch


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  def self.destroyed
    where(Solrizer.solr_name("workflow_metadata__destroyed", :symbol) => "true")
  end

  has_attributes :format, :type, :location, :created, :description, :rights, :title, :modified, :date, :datastream => :descMetadata, :multiple => false
  has_attributes :identifier, :lcsubject, :set, :creator, :contributor, :institution, :datastream => :descMetadata, :multiple => true

  private

  def queue_fetch
    skip_queue ? self.skip_queue = nil : Resque.enqueue(FetchAllJob,pid)
  end

  def check_derivatives
    @needs_derivatives = (content.content_changed? && !content.content.blank?)
    true
  end

  def queue_derivatives
    ::Resque.enqueue(::CreateDerivativesJob,pid) if @needs_derivatives
  end

end
