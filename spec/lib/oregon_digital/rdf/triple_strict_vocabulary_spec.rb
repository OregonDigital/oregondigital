require 'spec_helper'

describe OregonDigital::RDF::TripleStrictVocabulary do
  let(:rdf_subject) {"http://opaquenamespace.org/ns/test/bla"}
  let(:example_vocab) do
    class ExampleVocab < OregonDigital::RDF::TripleStrictVocabulary("http://opaquenamespace.org/ns/test/")
    end
    ExampleVocab
  end
  let(:method) {"bla"}
  subject { example_vocab }
  before do
    example_vocab
  end
  after do
    Object.send(:remove_const, "ExampleVocab")
  end
  context "when a method is called" do
    context "and it doesn't exist in the triple store" do
      it "should raise a no method error" do
        expect{subject.send(method)}.to raise_error(NoMethodError)
      end
    end
    context "and it exists in the triple store" do
      before do
        class TestResource < ActiveFedora::Rdf::Resource
          configure :repository => :vocabs
        end
        resource = TestResource.new("http://opaquenamespace.org/ns/test/#{method}")
        resource << RDF::Statement.new(resource.rdf_subject, RDF::SKOS.prefLabel, "Test Label")
        resource.persist!
      end
      after do
        Object.send(:remove_const, "TestResource")
      end
      it "should be defined" do
        expect(subject).to respond_to(method)
        expect(subject.send(method).to_s).to eq "http://opaquenamespace.org/ns/test/bla"
      end
    end
  end
end
