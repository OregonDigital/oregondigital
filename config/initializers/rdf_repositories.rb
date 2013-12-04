OregonDigital::RdfRepositories.add_repository :default, RDF::FourStore::Repository.new('http://data.library.oregonstate.edu:8001/')
OregonDigital::RdfRepositories.add_repository :vocabs, RDF::Repository.new
