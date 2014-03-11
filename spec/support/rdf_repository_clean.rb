RSpec.configure do |config|

  config.before(:each) do
    ActiveFedora::Rdf::Repositories.repositories.each do |key, repository|
      repository.clear
    end
  end
end
