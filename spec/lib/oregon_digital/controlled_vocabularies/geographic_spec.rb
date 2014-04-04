require 'spec_helper'

describe OregonDigital::ControlledVocabularies::Geographic do
  it_behaves_like 'a controlled vocabulary'

  subject { OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/5735238/') }

  describe '#rdf_label' do
    before do
      subject.name = 'Klamath Falls'
    end

    context 'without parent features' do
      it 'should return simple label' do
        expect(subject.rdf_label).to eq ['Klamath Falls']
      end
    end

    context 'with parent feature' do
      before do
        subject.parentFeature = OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/5735237/')
        subject.parentFeature.first.name = 'Klamath County'
        subject.parentFeature.first.parentFeature = OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/5744337/')
        subject.parentFeature.first.parentFeature.first.name = 'Oregon'
        subject.parentFeature.first.parentFeature.first.parentFeature = OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/6252001/')
        subject.parentFeature.first.parentFeature.first.parentFeature.first.name = 'United States'
      end

      it 'should return an extended, disambiguatied label' do
        expect(subject.rdf_label).to eq ['Klamath Falls >> Klamath County >> Oregon >> United States']
      end

      it 'should terminate label if parentFeature label is a uri' do 
        subject.parentFeature.first.parentFeature.first.name = nil
        expect(subject.rdf_label).to eq ['Klamath Falls >> Klamath County']
      end

      it 'should terminate label if parentFeature is not an ActiveFedora::Rdf::Resource' do 
        subject.parentFeature.first.parentFeature = 'Oregon'
        expect(subject.rdf_label).to eq ['Klamath Falls >> Klamath County']
      end
    end
  end

  describe '#fetch' do
    before do
      subject.name = 'Klamath Falls'
    end
    context "with parent features" do
      before do
        subject.parentFeature = OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/4735237/')
      end
      it "should call fetch on those features" do
        expect(subject.parentFeature.first).to receive(:fetch).and_return(true)
        subject.fetch
      end
      it "should persist parent features" do
        expect(subject.parentFeature.first).to receive(:persist!)
        subject.persist!
      end
    end
  end

end
