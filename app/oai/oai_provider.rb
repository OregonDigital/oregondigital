class OaiProvider < OAI::Provider::Base
  repository_name 'Oregon Digital OAI Provider'
  repository_url 'http://oregondigital.library.oregonstate.edu/provider'
  record_prefix 'oai:oregondigital'
  admin_email 'trey.terrell@oregonstate.edu'
  sample_id 'oai:oregondigital:13000'
  source_model ::Model::ActiveFedoraWrapper.new(::GenericAsset)
end