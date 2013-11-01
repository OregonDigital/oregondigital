require 'spec_helper'

describe OregonDigital::SpiraObject do
  before(:all) do
    @content = File.open(File.join(fixture_path, 'fixture_ntriples.nt')).read
  end
  let(:content) {}
  let(:uri) {"http://oregondigital.org/resource/oregondigital:test"}
  describe ".for" do
    context "when given a subject" do
      context "as a URI" do
        subject {OregonDigital::SpiraObject.for(RDF::URI.new(uri))}
        it "should set that URI as the subject" do
          expect(subject.subject).to eq RDF::URI.new(uri)
        end
      end
      context "as a string" do
        subject{OregonDigital::SpiraObject.for(uri)}
        it "should set that string's URI as a subject" do
          expect(subject.subject).to eq RDF::URI.new(uri)
        end
      end
    end
    context "when given content" do
      subject{OregonDigital::SpiraObject.for(uri, :content => @content)}
      it "should populate a transient repository with that initial content" do
        expect(RDF::NTriples::Writer.dump(subject)).to eq @content+"\n"
      end
    end
  end
end
