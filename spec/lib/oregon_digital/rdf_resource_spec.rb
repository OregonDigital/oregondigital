require "spec_helper"
describe OregonDigital::RdfResource do

  before(:each) do
    class DummyResource < OregonDigital::RdfResource
      property :title, :predicate => RDF::DC.title
    end
  end
  after(:each) do
    Object.send(:remove_const, "DummyResource") if Object
  end

  subject { DummyResource.new }

  describe 'subject' do
    it "should be a blank node if we haven't set it" do
      expect(subject.subject.node?).to be_true
    end
    it "should be settable" do
      subject.set_subject! RDF::URI('http://example.org/moomin')
      expect(subject.subject).to eq RDF::URI('http://example.org/moomin')
    end
    it "should edit graph when changing subject" do
      subject.title = ['Comet in Moominland']
      subject.set_subject! RDF::URI('http://example.org/moomin')
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

  describe '#set_value' do
    it 'should set a value in the graph' do
      subject.set_value(RDF::DC.title, 'Comet in Moominland')
      subject.query(:subject => subject.subject, :predicate => RDF::DC.title).each_statement do |s|
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
  end

  describe 'editing the graph' do
    it 'should write properties when statements are added' do
      subject << RDF::Statement.new(subject.subject, RDF::DC.title, 'Comet in Moominland')
      expect(subject.title).to include 'Comet in Moominland'
    end
    it 'should delete properties when statements are removed' do
      subject << RDF::Statement.new(subject.subject, RDF::DC.title, 'Comet in Moominland')
      subject.delete RDF::Statement.new(subject.subject, RDF::DC.title, 'Comet in Moominland')
      expect(subject.title).to eq []
    end
  end
end
