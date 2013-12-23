require "spec_helper"
describe OregonDigital::RDF::RdfResource do

  before(:each) do
    class DummyLicense < OregonDigital::RDF::RdfResource
      map_predicates do |map|
        map.title(:in => RDF::DC)
      end
    end

    class DummyResource < OregonDigital::RDF::RdfResource
      configure :type => RDF::URI('http://example.org/SomeClass')
      property :license, :predicate => RDF::DC.license, :class_name => DummyLicense
      map_predicates do |map|
        map.title(:in => RDF::DC)
      end
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyResource") if Object
    Object.send(:remove_const, "DummyLicense") if Object
  end

  subject { DummyResource.new }

  describe 'rdf_subject' do
    it "should be a blank node if we haven't set it" do
      expect(subject.rdf_subject.node?).to be_true
    end
    it "should be settable" do
      subject.set_subject! RDF::URI('http://example.org/moomin')
      expect(subject.rdf_subject).to eq RDF::URI('http://example.org/moomin')
    end
    describe 'when changing subject' do
      before(:each) do
        subject << RDF::Statement.new(subject.rdf_subject, RDF::DC.title, RDF::Literal('Comet in Moominland'))
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.isPartOf, subject.rdf_subject)
        subject << RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.relation, 'http://example.org/moomin_land')
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end
      it 'should update graph subjects' do
        expect(subject.has_statement?(RDF::Statement.new(subject.rdf_subject, RDF::DC.title, RDF::Literal('Comet in Moominland')))).to be_true
      end
      it 'should update graph objects' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.isPartOf, subject.rdf_subject))).to be_true
      end
      it 'should leave other uris alone' do
        expect(subject.has_statement?(RDF::Statement.new(RDF::URI('http://example.org/moomin_comics'), RDF::DC.relation, 'http://example.org/moomin_land'))).to be_true
      end
    end
    describe 'with URI subject' do
      before(:each) do
        subject.set_subject! RDF::URI('http://example.org/moomin')
      end
      it 'should not be settable' do
        expect{ subject.set_subject! RDF::URI('http://example.org/moomin2') }.to raise_error
      end
    end
  end

  describe "#persisted?" do
    before(:each) do
      repository = RDF::Repository.new
      subject.stub(:repository).and_return(repository)
    end
    context "when the object is new" do
      it "should return false" do
        expect(subject).not_to be_persisted
      end
    end
    context "when it is saved" do
      before(:each) do
        subject.title = "bla"
        subject.persist!
      end
      it "should return true" do
        expect(subject).to be_persisted
      end
      context "and then modified" do
        before(:each) do
          subject.title = "newbla"
        end
        it "should return true" do
          expect(subject).to be_persisted
        end
      end
      context "and then reloaded" do
        before(:each) do
          subject.reload
        end
        it "should reset the title" do
          expect(subject.title).to eq ["bla"]
        end
        it "should be persisted" do
          expect(subject).to be_persisted
        end
      end
    end
  end

  describe 'property methods' do
    it 'should set and get properties' do
      subject.title = 'Comet in Moominland'
      expect(subject.title).to eq ['Comet in Moominland']
    end
  end

  describe 'child nodes' do
    it 'should return an object of the correct class when the value is a URI' do
      subject.license = DummyLicense.new('http://example.org/license')
      expect(subject.license.first).to be_kind_of DummyLicense
    end
    it 'should return an object with the correct URI when the value is a URI ' do
      subject.license = DummyLicense.new('http://example.org/license')
      expect(subject.license.first.rdf_subject).to eq RDF::URI("http://example.org/license")
    end
    it 'should return an object of the correct class when the value is a bnode' do
      subject.license = DummyLicense.new
      expect(subject.license.first).to be_kind_of DummyLicense
    end
  end

  describe '#set_value' do
    it 'should set a value in the graph' do
      subject.set_value(RDF::DC.title, 'Comet in Moominland')
      subject.query(:subject => subject.rdf_subject, :predicate => RDF::DC.title).each_statement do |s|
        expect(s.object.to_s).to eq 'Comet in Moominland'
      end
    end
    it 'should set a value in the when given a registered property symbol' do
      subject.set_value(:title, 'Comet in Moominland')
      expect(subject.title).to eq ['Comet in Moominland']
    end
    it "raise an error if the value is not a URI, Node, Literal, RdfResource, or string" do
      expect{subject.set_value(RDF::DC.title, Object.new)}.to raise_error
    end
    it "should be able to accept a subject" do
      expect{subject.set_value(RDF::URI("http://opaquenamespace.org/jokes"), RDF::DC.title, 'Comet in Moominland')}.not_to raise_error
      expect(subject.query(:subject => RDF::URI("http://opaquenamespace.org/jokes"), :predicate => RDF::DC.title).statements.to_a.length).to eq 1
    end
  end
  describe '#get_values' do
    before(:each) do
      subject.title = ['Comet in Moominland', "Finn Family Moomintroll"]
    end
    it 'should return values for a predicate uri' do
      expect(subject.get_values(RDF::DC.title)).to eq ['Comet in Moominland', 'Finn Family Moomintroll']
    end
    it 'should return values for a registered predicate symbol' do
      expect(subject.get_values(:title)).to eq ['Comet in Moominland', 'Finn Family Moomintroll']
    end
    it "should return values for other subjects if asked" do
      expect(subject.get_values(RDF::URI("http://opaquenamespace.org/jokes"),:title)).to eq []
      subject.set_value(RDF::URI("http://opaquenamespace.org/jokes"), RDF::DC.title, 'Comet in Moominland')
      expect(subject.get_values(RDF::URI("http://opaquenamespace.org/jokes"),:title)).to eq ["Comet in Moominland"]
    end
  end

  describe '#type' do
    it 'should return the type configured on the parent class' do
      expect(subject.type).to eq DummyResource.type
    end

    it 'should set the type' do
      subject.type = RDF::URI('http://example.org/AnotherClass')
      expect(subject.type).to eq RDF::URI('http://example.org/AnotherClass')
    end

    it 'should be the type in the graph' do
      subject.query(:subject => subject.rdf_subject, :predicate => RDF.type).statements do |s|
        expect(s.object).to eq RDF::URI('http://example.org/AnotherClass')
      end
    end
  end

  describe '#rdf_label' do
    it 'should return the configured label values'
  end

  describe 'editing the graph' do
    it 'should write properties when statements are added' do
      subject << RDF::Statement.new(subject.rdf_subject, RDF::DC.title, 'Comet in Moominland')
      expect(subject.title).to include 'Comet in Moominland'
    end
    it 'should delete properties when statements are removed' do
      subject << RDF::Statement.new(subject.rdf_subject, RDF::DC.title, 'Comet in Moominland')
      subject.delete RDF::Statement.new(subject.rdf_subject, RDF::DC.title, 'Comet in Moominland')
      expect(subject.title).to eq []
    end
  end

  describe 'controlled vocabularies' do
    before(:each) do
      RDF_VOCABS[:dcmitype] = { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' }
      RDF_VOCABS[:geonames] = { :prefix => 'http://sws.geonames.org/', :strict => false, :fetch => false }
      class DummyStrict < OregonDigital::RDF::RdfResource
        include OregonDigital::RDF::Controlled
        use_vocabulary :dcmitype
      end
      class DummyVocab < OregonDigital::RDF::RdfResource
        include OregonDigital::RDF::Controlled
        use_vocabulary :geonames
      end
      DummyResource.property(:type, :predicate => RDF::DC.type, :class_name => DummyStrict)
      DummyResource.property(:geo, :predicate => RDF::DC.spatial, :class_name => DummyVocab)
      subject.type = DummyStrict.new('Image')
      subject.geo = DummyVocab.new('http://sws.geonames.org/5735237/')
    end
    after(:each) do
      Object.send(:remove_const, 'DummyStrict') if Object
      Object.send(:remove_const, 'DummyVocab') if Object
    end

    it 'should accept controlled terms' do
      expect(subject.type.first).to be_kind_of DummyStrict
    end
    it 'should accept uncontrolled external terms' do
      expect(subject.geo.first).to be_kind_of DummyVocab
    end
    it 'should load data for controlled terms' do
      DummyStrict.load_vocabularies
      subject.reload
      expect(subject.type.first.has_subject?(RDF::URI('http://purl.org/dc/dcmitype/Image'))).to be_true
    end
    it 'should load data for uncontrolled external terms' do
      subject.geo.first.fetch
      expect(subject.geo.first.has_subject?(RDF::URI('http://sws.geonames.org/5735237/'))).to be_true
    end
  end

  describe 'big complex graphs' do
    it 'should allow access to deep nodes'
    it 'should reload when parent is reloaded'
    context 'loaded into parent resource' do
      it 'should persist subgraphs to correct repositories'
    end
  end
end
