require "spec_helper"

describe OregonDigital::RDF::Controlled do

  before(:each) do
    class DummyAuthority < ActiveFedora::Rdf::Resource
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

  describe '#list_terms' do
    it 'should list terms from registered StrictVocabs' do
      subject.vocabularies.each do |name, vocab|
        expect([vocab[:class].Image] - subject.list_terms).to be_empty
      end
    end
    it 'should list only terms from registered StrictVocabs' do
      terms = []
      subject.vocabularies.each do |name, vocab|
        terms += vocab[:class].properties
      end
      expect(subject.list_terms - terms).to be_empty
    end
  end

  describe '#rdf_label' do
    subject {DummyAuthority.new}
    context "when there are only plain labels" do
      before do
        subject.title = ["English", "French"]
      end
      it "should return both" do
        expect(subject.title).to eq ["English", "French"]
      end
    end
    context "when there are english labels" do
      before do
        subject.title = RDF::Literal.new("English", :langauge => :en)
      end
      context "and plain labels" do
        before do
          subject.title = ["Plain", RDF::Literal.new("English", :language => :en)]
        end
        it "should return the english label" do
          expect(subject.rdf_label).to eq ["English"]
        end
      end
      context "and other language labels" do
        before do
          subject.title = [RDF::Literal.new("French", :language => :fr), RDF::Literal.new("English", :language => :en)]
        end
        it "should return the english label" do
          expect(subject.rdf_label).to eq ["English"]
        end
      end
    end
  end

  describe '#load_vocabularies' do
    it 'should load data' do
      subject.load_vocabularies
      expect(subject.new('Image').has_subject?(RDF::URI('http://purl.org/dc/dcmitype/Image'))).to be_true
    end
  end

  describe '#search' do
    before do
      image = subject.new('Image')
      image << RDF::Statement(image.rdf_subject, RDF::SKOS.prefLabel, "Image")
      image.persist!
    end

    it 'should return matches' do
      expect(subject.new.search('Image').first[:id]).to eq RDF::URI('http://purl.org/dc/dcmitype/Image')
    end
    it 'should search case insensitively' do
      expect(subject.new.search('ima').first[:id]).to eq RDF::URI('http://purl.org/dc/dcmitype/Image')
    end
    describe 'non-label matches' do
      before do
        doc = subject.new('Text')
        doc << RDF::Statement(doc.rdf_subject, RDF::DC.description, "This is not an image!")
        doc.persist!
      end

      it 'should return non-label matches if no label matches exist' do
        image = subject.new('Image')
        image.clear
        image.persist!
        expect(subject.new.search('ima').map { |result| result[:id] } ).to include subject.new('Text').rdf_subject
      end
      it 'should not return non-label matches if label matches exist' do
        expect(subject.new.search('ima').map { |result| result[:id] } ).not_to include subject.new('Text').rdf_subject
      end
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
