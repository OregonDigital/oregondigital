shared_examples 'a controlled vocabulary' do
  subject { described_class }

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
end
