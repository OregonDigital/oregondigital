OregonDigital::RDF::RdfRepositories.add_repository :default, RDF::Redis.new
OregonDigital::RDF::RdfRepositories.add_repository :vocabs, RDF::Redis.new(:name => :vocabs)
