class GenericAsset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Collectible
  include OregonDigital::Workflow
  include OregonDigital::OAI::Concern
  include ActiveFedora::Rdf::Identifiable
  include OregonDigital::RDF::Identifiable

  has_metadata :name => 'descMetadata', :type => Datastream::OregonRDF do |ds|
    ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => "RELS-EXT",
                 :transform => Proc.new {|x| x.gsub('info:fedora/','')},
                 :reverse_transform => Proc.new {|x| "info:fedora/#{x}"}
  end
  has_metadata :name => 'rightsMetadata', :type =>
    Datastream::RightsMetadata

  has_file_datastream name: 'content', type: Datastream::Content

  before_save :check_derivatives
  after_save :queue_derivatives


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  has_attributes :hasFormat, :type, :location, :created, :description, :rights, :title, :modified, :date, :datastream => :descMetadata, :multiple => false
  has_attributes :identifier, :subject, :set, :creator, :contributor, :datastream => :descMetadata, :multiple => true

  private

  def check_derivatives
    @needs_derivatives = (content.content_changed? && !content.content.blank?)
    true
  end

  def queue_derivatives
    Resque.enqueue(CreateDerivativesJob,pid) if @needs_derivatives
  end

end
