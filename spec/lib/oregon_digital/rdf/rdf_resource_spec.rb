require "spec_helper"
describe OregonDigital::RDF::RdfResource do

  before(:each) do
    class DummyLicense < OregonDigital::RDF::RdfResource
      map_predicates do |map|
        map.title(:in => RDF::DC)
      end
    end

    class DummyResource < OregonDigital::RDF::RdfResource
      configure :type => RDF::DC['SomeClass']
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
    it "should edit graph when changing subject" do
      subject.title = ['Comet in Moominland']
      subject.set_subject! RDF::URI('http://example.org/moomin')
      subject.statements.each do |statement|
        expect(statement.subject).to eq RDF::URI('http://example.org/moomin')
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
    it 'should return an RdfResource object when the value is a bnode' do
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
      subject.type = RDF::DC['AnotherClass']
      expect(subject.type).to eq RDF::DC['AnotherClass']
    end

    it 'should be the type in the graph' do
      subject.query(:subject => subject.rdf_subject, :predicate => RDF::RDFS.type).statements do |s|
        expect(s.object).to eq RDF::DC['AnotherClass']
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
end
