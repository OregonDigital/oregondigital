class GenericAsset < ActiveFedora::Base
  include Hydra::ModelMixins::CommonMetadata
  include Hydra::ModelMethods

  has_metadata :name => 'descMetadata', :type => OregonRDFDatastream
  has_metadata :name => 'rightsMetadata', :type =>
    Hydra::Datastream::RightsMetadata

  has_file_datastream name: 'content'

end
