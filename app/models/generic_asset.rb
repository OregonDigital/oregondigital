class GenericAsset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Collectible
  include OregonDigital::Workflow

  has_metadata :name => 'descMetadata', :type => Datastream::OregonRDF do |ds|
    ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => "RELS-EXT",
                 :transform => Proc.new {|x| x.gsub('info:fedora/','')},
                 :reverse_transform => Proc.new {|x| "info:fedora/#{x}"}
  end
  has_metadata :name => 'rightsMetadata', :type =>
    Hydra::Datastream::RightsMetadata

  has_file_datastream name: 'content', type: Datastream::Content

  before_save :check_derivatives
  after_save :queue_derivatives


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  delegate_to :descMetadata, [:hasFormat, :type, :location, :created, :description, :rights, :title, :modified, :date], :multiple => false
  delegate_to :descMetadata, [:identifier, :subject, :set], :multiple => true

  private

  def check_derivatives
    @needs_derivatives = (content.content_changed? && !content.content.blank?)
    true
  end

  def queue_derivatives
    Resque.enqueue(CreateDerivativesJob,pid) if @needs_derivatives
  end

end
