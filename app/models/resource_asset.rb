class ResourceAsset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Collectible
  include OregonDigital::Workflow

  has_metadata :name => 'descMetadata', :type => Datastream::OregonResource
  has_metadata :name => 'rightsMetadata', :type =>
    Hydra::Datastream::RightsMetadata

  has_file_datastream name: 'content', type: Datastream::Content


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  delegate_to :descMetadata, [:hasFormat, :type, :location, :created, :description, :rights, :title, :modified, :date], :multiple => false
  delegate_to :descMetadata, [:identifier, :subject, :set], :multiple => true

end
