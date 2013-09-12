class GenericAsset < ActiveFedora::Base
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMethods
  include Hybag::Baggable
  include Hydra::Derivatives

  has_metadata :name => 'descMetadata', :type => OregonRDFDatastream
  has_metadata :name => 'rightsMetadata', :type =>
    Hydra::Datastream::RightsMetadata

  has_file_datastream name: 'content'

  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  delegate_to :descMetadata, [:hasFormat, :type, :location, :created, :description, :rights, :title, :modified, :date], :unique => true
  delegate_to :descMetadata, [:identifier, :subject, :set]

end
