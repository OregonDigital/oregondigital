
Rails.application.config.to_prepare do
  if Rails.env.test?
    ActiveFedora::Rdf::Repositories.add_repository :default, RDF::Repository.new
    ActiveFedora::Rdf::Repositories.add_repository :vocabs, RDF::Repository.new
  else
    ActiveFedora::Rdf::Repositories.add_repository :default, RDF::Mongo::Repository.new
    ActiveFedora::Rdf::Repositories.add_repository :vocabs, RDF::Mongo::Repository.new(:collection => 'vocabs')
  end
end
