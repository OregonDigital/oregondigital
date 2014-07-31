require 'spec_helper'

describe OregonDigital::BagIngestible do
  let(:dir) { './fake_dir' }
  let(:bag) { FactoryGirl.create(:generic_asset, :with_jpeg_datastream).write_bag }
  let(:object_resource) {
    o = OregonDigital::RDF::ObjectResource.new('http://example.org/blah')
    o << RDF::Statement(o, RDF::DC.title, 'my_title') 
    o << RDF::Statement(o, RDF::DC.relation, RDF::URI('http://example.org/blah'))
  }

  before do
    # TODO: patch Hybag to dump workflow metadata to the correct place, 
    # and remove the following line
    bag.remove_file('workflowMetadata.bin') 

    bag.add_tag_file('descMetadata.nt') { |io| io.write object_resource.dump(:ntriples) }
    Hybag::BulkIngester.any_instance.stub(:each).
      and_yield(Hybag::Ingester.new(bag))
  end

  describe '#bulk_ingest_bags' do
    it 'returns assets' do
      result = GenericAsset.bulk_ingest_bags(dir)
      expect(result).to be_a Array
      expect(result.first).to be_a GenericAsset
    end

    it 'casts assets to model' do
      expect(GenericAsset.bulk_ingest_bags(dir).first).to be_a Image
    end

    it 'rewrites statements with rdf_subject/pid' do
      asset = GenericAsset.bulk_ingest_bags(dir).first
      expect(asset.title).to eq 'my_title'
    end

    it 'adds mimetype to content datastream' do
      expect(GenericAsset.bulk_ingest_bags(dir).first.content.mimeType).to eq 'image/jpeg'
    end

    it 'adds mimetype as format' do
      expect(GenericAsset.bulk_ingest_bags(dir).first.format.rdf_subject).to eq RDF::URI('http://purl.org/NET/mediatypes/image/jpeg')
    end

    it 'retains all statements from original graph' do
      expect(GenericAsset.bulk_ingest_bags(dir).first.descMetadata.resource.count).to eq (object_resource.count + 1)
    end
  end
  
end
