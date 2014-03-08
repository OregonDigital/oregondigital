class Datastream::RightsMetadata < Hydra::Datastream::RightsMetadata

  # Override prefix to quiet AF7 deprecation warnings.
  def prefix
    "rights_metadata__"
  end
end
