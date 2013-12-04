module OregonDigital
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
