
Rails.application.config.to_prepare do
  if Rails.env.test?
    ActiveFedora::Rdf::Repositories.add_repository :default, RDF::Repository.new
    ActiveFedora::Rdf::Repositories.add_repository :vocabs, RDF::Repository.new
  else
    ActiveFedora::Rdf::Repositories.add_repository :default, RDF::Redis.new
    ActiveFedora::Rdf::Repositories.add_repository :vocabs, RDF::Redis.new(:name => :vocabs)
  end
end
