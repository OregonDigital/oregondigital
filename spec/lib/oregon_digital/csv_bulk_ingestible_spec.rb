require 'spec_helper'

describe OregonDigital::CsvBulkIngestible do
  before do
    class CsvIngestAsset < ActiveFedora::Base
      extend OregonDigital::CsvBulkIngestible

      has_metadata :name => 'descMetadata', :type => Datastream::OregonRDF
      has_attributes :title, :creator, :location, :set, :datastream => :descMetadata, :multiple => true

      has_file_datastream name: 'content', type: Datastream::Content
    end
    GenericCollection.new(:pid => 'oregondigital:moomin-collection').save
    GenericCollection.new(:pid => 'oregondigital:moomin-valley-historical').save
  end

  after do
    Object.send(:remove_const, "CsvIngestAsset")
  end

  subject { CsvIngestAsset }
  let(:dir) { './csv_dir' }
  let(:headers) { ['ingest filename', 'title', 'creator', 'set', 'location', 'rights holder'] }
  let(:sym_headers) { [:ingest_filename, :title, :creator, :set, :location, :rights_holder] }

  shared_context 'with test files' do
    before do
      IO.stub(:binread).and_call_original
      IO.stub(:binread).with(File.join(dir, '1.txt')).and_return('test file 1')
      IO.stub(:binread).with(File.join(dir, '2.txt')).and_return('test file 2')
      IO.stub(:binread).with(File.join(dir, '3.txt')).and_raise(Errno::ENOENT.new('3.txt'))
      FileMagic.any_instance.stub(:file).and_return("text/plain; charset=us-ascii")
    end
  end

  shared_context 'with good csv metadata' do
    include_context 'with test files'
    before do
      Dir.stub(:glob).and_call_original
      Dir.stub(:glob).with(File.join(dir, '*.csv')).and_return([File.join(dir, 'test.csv')])
      CSV.stub(:foreach).with(File.join(dir, 'test.csv'), :headers => true, :header_converters => :symbol).
        and_yield(CSV::Row.new(sym_headers, ['1.txt', 'Fake 1', 'Moomin Pappa', 'moomin-collection', 'http://sws.geonames.org/5720727/'])).
        and_yield(CSV::Row.new(sym_headers, ['2.txt', '   ', 'Moomin Pappa|Snuffkin', 'moomin-collection|moomin-valley-historical', '']))
    end
  end

  shared_context 'with bad field in csv metadata' do
    include_context 'with test files'
    before do
      Dir.stub(:glob).and_call_original
      Dir.stub(:glob).with(File.join(dir, '*.csv')).and_return([File.join(dir, 'test.csv')])
      CSV.stub(:foreach).with(File.join(dir, 'test.csv'), :headers => true, :header_converters => :symbol).
        and_yield(CSV::Row.new((sym_headers << :not_real_field), ['1.txt', 'Fake 1', 'Moomin Pappa', 'moomin-collection', 'http://sws.geonames.org/5720727/', "not real field's value"]))
    end
  end

  shared_context 'with bad value in csv metadata' do
    include_context 'with test files'
    before do
      Dir.stub(:glob).and_call_original
      Dir.stub(:glob).with(File.join(dir, '*.csv')).and_return([File.join(dir, 'test.csv')])
      CSV.stub(:foreach).with(File.join(dir, 'test.csv'), :headers => true, :header_converters => :symbol).
        and_yield(CSV::Row.new(sym_headers, ['1.txt', 'Fake 1', 'Moomin Pappa', 'moomin-collection', 'Corvallis'])).
        and_yield(CSV::Row.new(sym_headers, ['2.txt', 'Fake 2', 'Moomin Pappa', 'mmmooooomin', 'http://sws.geonames.org/5720727/']))
    end
  end

  shared_context 'with bad filename' do
    include_context 'with test files'
    before do
      Dir.stub(:glob).and_call_original
      Dir.stub(:glob).with(File.join(dir, '*.csv')).and_return([File.join(dir, 'test.csv')])
      CSV.stub(:foreach).with(File.join(dir, 'test.csv'), :headers => true, :header_converters => :symbol).
        and_yield(CSV::Row.new(sym_headers, ['3.txt', 'Fake 3', 'Moomin Pappa', 'moomin-collection', '']))
    end
  end

  describe '#assets_from_csv' do
    let(:assets) { subject.assets_from_csv(dir) }
    
    context 'with valid metadata' do
      include_context 'with good csv metadata'

      it 'should return an array of assets' do
        expect(subject.assets_from_csv(dir)).to be_a Array
        expect(subject.assets_from_csv(dir).first).to be_a subject
      end

      it 'should add literal values from csv' do
        expect(assets.first.title).to eq ['Fake 1']
      end

      it 'should add OregonDigital::Set values' do
        expect(assets.first.set.map(&:pid)).to eq ['oregondigital:moomin-collection']
        expect(assets[1].set.map(&:pid)).to eq ['oregondigital:moomin-collection', 'oregondigital:moomin-valley-historical']
      end

      it 'should add URI values' do
        expect(assets.first.location).to eq [OregonDigital::ControlledVocabularies::Geographic.new('http://sws.geonames.org/5720727/')]
      end

      it 'should handle empty values' do
        expect(assets[1].location).to eq []
      end
      
      it 'should handle whitespace values' do
        expect(assets[1].title).to eq []
      end
    end

    context 'with invalid fields' do
      include_context 'with bad field in csv metadata'
      it 'should throw an error with list of bad fields' do
        expect { assets }.to raise_error { |error|
          expect(error).to be_a(OregonDigital::CsvBulkIngestible::CsvBatchError)
          expect(error.field_errors).to eq [:not_real_field]
        }
      end
    end

    context 'with invalid values' do
      include_context 'with bad value in csv metadata'
      it 'should throw an error with list of bad values' do
        expect { assets }.to raise_error { |error|
          error.should be_a(OregonDigital::CsvBulkIngestible::CsvBatchError)
          error.value_errors.should eq [['Corvallis', 'Term not in controlled vocabularies: Corvallis'],['mmmooooomin', "no GenericCollection found with pid 'mmmooooomin'"]]
        }
      end
    end


  end
  
  describe '#ingest_from_csv' do

    let(:assets) { subject.ingest_from_csv(dir) }

    context 'with good csv metadata' do
      include_context 'with good csv metadata'
      it 'should ingest asset contents' do
        expect(assets.first.content.content).to eq 'test file 1'
      end
      it 'should save assets' do
        expect(assets.first).to be_persisted
      end
      it 'should set mimetype' do
        expect(assets.first.content.mimeType).to eq 'text/plain'
      end
    end


    context 'when an error is caught' do
      it 'should not save assets from batch' 
    end

    context 'with invalid file' do
      include_context 'with bad filename'
      it 'should throw an error with list of bad filenames' do
        expect { assets }.to raise_error { |error|
          error.should be_a(OregonDigital::CsvBulkIngestible::CsvBatchError)
          error.file_errors.should eq ['3.txt']
        }
      end
    end
  end
end
