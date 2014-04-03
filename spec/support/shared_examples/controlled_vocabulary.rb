shared_examples 'a controlled vocabulary' do
  subject { described_class }

  it 'should have at least one vocabulary' do
    expect(subject.vocabularies.length).to be >= 1
  end

  describe 'vocabularies' do
    it 'should have a vocabulary uri' do
      subject.vocabularies.each do |k, v|
        expect(v[:class]).to respond_to :to_uri
      end
    end
  end

  describe '#qa_interface' do
    it 'should have a qa_interface' do
      expect(subject.qa_interface).to respond_to :search
    end

    describe '#search' do
      it 'should return a list of results' do
        expect(subject.qa_interface.search('blah')).to be_kind_of Array
      end
    end
  end

  describe '#search' do
    it 'should return a list of results' do
      expect(subject.new.search('blah')).to be_kind_of Array
    end
  end
end
