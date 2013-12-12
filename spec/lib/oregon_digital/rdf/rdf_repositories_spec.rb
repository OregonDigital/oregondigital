require "spec_helper"
describe OregonDigital::RDF::RdfRepositories do
  subject {OregonDigital::RDF::RdfRepositories}
  before do
    subject.clear_repositories!
  end

  after(:each) do
    subject.clear_repositories!
  end

  it 'should default to an empty hash' do
    expect(subject.repositories).to be_empty
  end

  describe 'adding repositories' do
    it 'should accept a new repository' do
      subject.add_repository :name, RDF::Repository.new
      expect(subject.repositories).to include :name
    end
    it 'should throw an error if passed something that is not a repository' do
      expect{subject.add_repository :name, :not_a_repo}.to raise_error
    end
  end

  describe '#clear_repositories!' do
    before(:each) do
      subject.add_repository :name, RDF::Repository.new
      subject.add_repository :name2, RDF::Repository.new
    end
    it 'should empty the repositories list' do
      subject.clear_repositories!
      expect(subject.repositories).to be_empty
    end

  end

end
