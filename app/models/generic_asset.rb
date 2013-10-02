class GenericAsset < ActiveFedora::Base
  include Hydra::ModelMixins::RightsMetadata
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Collectible
  include OregonDigital::Workflow

  has_metadata :name => 'descMetadata', :type => OregonRDFDatastream do |ds|
    ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => "RELS-EXT"
  end
  has_metadata :name => 'rightsMetadata', :type =>
    Hydra::Datastream::RightsMetadata

  has_file_datastream name: 'content', type: ContentDatastream


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  delegate_to :descMetadata, [:hasFormat, :type, :location, :created, :description, :rights, :title, :modified, :date], :unique => true
  delegate_to :descMetadata, [:identifier, :subject, :set]

end
