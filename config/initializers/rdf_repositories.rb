
Rails.application.config.to_prepare do
  if Rails.env.test?
    OregonDigital::RDF::RdfRepositories.add_repository :default, RDF::Repository.new
    OregonDigital::RDF::RdfRepositories.add_repository :vocabs, RDF::Repository.new
  else
    OregonDigital::RDF::RdfRepositories.add_repository :default, RDF::Redis.new
    OregonDigital::RDF::RdfRepositories.add_repository :vocabs, RDF::Redis.new(:name => :vocabs)
  end
end
