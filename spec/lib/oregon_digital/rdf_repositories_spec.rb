require "spec_helper"
describe OregonDigital::RdfRepositories do
  before do
    OregonDigital::RdfRepositories.clear_repositories!
  end

  after(:each) do
    OregonDigital::RdfRepositories.clear_repositories!
  end

  it 'should default to an empty hash' do
    expect(OregonDigital::RdfRepositories.repositories).to be_empty
  end

  describe 'adding repositories' do
    it 'should accept a new repository' do
      OregonDigital::RdfRepositories.add_repository :name, RDF::Repository.new
      expect(OregonDigital::RdfRepositories.repositories).to include :name
    end
    it 'should throw an error if passed something that is not a repository' do
      expect{OregonDigital::RdfRepositories.add_repository :name, :not_a_repo}.to raise_error
    end
  end

  describe '#clear_repositories!' do
    before(:each) do
      OregonDigital::RdfRepositories.add_repository :name, RDF::Repository.new
      OregonDigital::RdfRepositories.add_repository :name2, RDF::Repository.new
    end
    it 'should empty the repositories list' do
      OregonDigital::RdfRepositories.clear_repositories!
      expect(OregonDigital::RdfRepositories.repositories).to be_empty
    end

  end

end
