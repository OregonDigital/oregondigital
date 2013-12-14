require "spec_helper"
describe OregonDigital::RDF::Controlled do
  before(:each) do
    class DummyAuthority < OregonDigital::RDF::RdfResource
      include OregonDigital::RDF::Controlled
      use_vocabulary :dcmitype
      property :title, :predicate => RDF::DC.title
    end
  end

  after(:each) do
    Object.send(:remove_const, 'DummyAuthority') if Object
  end

  subject { DummyAuthority }

  describe 'vocabulary registration' do
    it 'should add vocabulary' do
      expect(subject.vocabularies).to include :dcmitype
    end
    it 'should find its vocabulary class' do
      expect(subject.vocabularies[:dcmitype][:class]).to eq OregonDigital::Vocabularies::DCMITYPE
    end
    it 'should know its vocabulary configuration' do
      RDF_VOCABS[:dcmitype].each do |name, value|
        expect(subject.vocabularies[:dcmitype][name]).to eq value
      end
    end
    it 'should allow multiple vocabularies' do
      subject.use_vocabulary :premis
      expect(subject.vocabularies).to include :dcmitype, :premis
    end
  end

  describe 'uris' do
    it 'should use a vocabulary uri' do
      dummy = DummyAuthority.new('Image')
      expect(dummy.rdf_subject).to eq OregonDigital::Vocabularies::DCMITYPE.Image
    end

    it 'should accept a full uri' do
      dummy = DummyAuthority.new(OregonDigital::Vocabularies::DCMITYPE.Image)
      expect(dummy.rdf_subject).to eq OregonDigital::Vocabularies::DCMITYPE.Image
    end

    it 'should accept a string for a full uri' do
      dummy = DummyAuthority.new(OregonDigital::Vocabularies::DCMITYPE.Image.to_s)
      expect(dummy.rdf_subject).to eq OregonDigital::Vocabularies::DCMITYPE.Image
    end

    it 'should raise an error if the term is not in the vocabulary' do
      expect{ DummyAuthority.new('FakeTerm') }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
    end

    it 'should raise an error if the uri is not in the vocabulary' do
      expect{ DummyAuthority.new(RDF::URI('http://example.org/blah')) }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
    end

    it 'should raise an error if the uri string is not in the vocabulary' do
      expect{ DummyAuthority.new('http://example.org/blah') }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
    end

    it 'should raise an error if the uri string is not in the vocabulary' do
      expect{ DummyAuthority.new(subject.vocabularies[:dcmitype][:prefix] + 'FakeTerm') }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
    end

    it 'should raise an error if the uri string just the prefix' do
      expect{ DummyAuthority.new(subject.vocabularies[:dcmitype][:prefix]) }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
    end

    context 'with non-strict vocabularies' do
      before(:each) do
        DummyAuthority.use_vocabulary :geonames
      end

      it 'should make uri for terms not defined' do
        expect(DummyAuthority.new('http://sws.geonames.org/FakeTerm').rdf_subject).to eq OregonDigital::Vocabularies::GEONAMES.FakeTerm
      end

      it 'should use strict uri when one is available' do
        expect(DummyAuthority.new('Image').rdf_subject).to eq OregonDigital::Vocabularies::DCMITYPE.Image
      end

      it 'should raise error for terms that are not clear' do
        DummyAuthority.use_vocabulary :oregondigital
        expect{ DummyAuthority.new('FakeTerm').rdf_subject }.to raise_error(OregonDigital::RDF::Controlled::ControlledVocabularyError)
      end
    end
  end

end
