module OregonDigital::RDF
  ##
  # Defines module methods for registering an RDF::Repository for
  # persistence of RdfResources.
  #
  # This allows any triplestore (or other storage platform) with an
  # RDF::Repository implementation to be used for persistence of
  # resources that will be shared between ActiveFedora::Base objects.
  #
  #    RdfRepositories.add_repository :blah, RDF::Repository.new
  #
  # Multiple repositories can be registered to keep different kinds of
  # resources seperate. This is configurable on subclasses of
  # RdfResource at the class level.
  #
  # @see RdfConfigurable
  module RdfRepositories

    def add_repository(name, repo)
      raise "Repositories must be an RDF::Repository" unless repo.kind_of? RDF::Repository
      repositories[name] = repo
    end
    module_function :add_repository

    def clear_repositories!
      @repositories = {}
    end
    module_function :clear_repositories!

    def repositories
      @repositories ||= {}
    end
    module_function :repositories

  end
end
