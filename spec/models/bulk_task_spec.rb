require 'spec_helper'

describe BulkTask do

  before do
    Dir.stub(:glob).and_call_original
    Dir.stub(:glob).with(File.join("/data1/batch/bulkloads", '*.csv')).and_return([File.join("/data1/batch/bulkloads", 'test.csv')])
  end
  
  subject { BulkTask.new :directory => 'bulkloads' }

  let(:assets) { [GenericAsset.new, GenericAsset.new, GenericAsset.new].map { |asset| asset.save; asset } }
  let(:pids) { assets.map { |asset| asset.pid } }

  it 'has csv type' do
    expect(subject.type).to eq :csv
  end

  context 'new object' do
    it 'is new' do
      expect(subject).to be_new
    end
  end
  
  describe 'assets' do
    before do
      subject.assets = assets
    end
    
    it 'has assets' do
      expect(subject.assets).to eq assets
    end
    
    it 'has asset ids' do
      expect(subject.asset_ids).to eq pids
    end
    
    context 'when resetting assets' do
      before do
        subject.assets = [GenericAsset.new, GenericAsset.new].map { |asset| asset.save; asset }
      end
      it 'overrides old assets' do
        expect(subject.assets).to eq assets
      end
    end
  end

  describe 'refresh' do
    before do
      File.stub(:directory?).and_call_original
      File.stub(:directory?).with(File.join(APP_CONFIG.batch_dir, 'test1')).and_return true
      File.stub(:directory?).with(File.join(APP_CONFIG.batch_dir, 'test2')).and_return true
      File.stub(:directory?).with(File.join(APP_CONFIG.batch_dir, 'test3')).and_return true
      Dir.stub(:glob).with(File.join(APP_CONFIG.batch_dir, '*')).and_return([File.join(APP_CONFIG.batch_dir, 'test1'), File.join(APP_CONFIG.batch_dir, 'test2'), File.join(APP_CONFIG.batch_dir, 'test3')])
    end

    it 'creates BulkTasks for folders found' do
      BulkTask.refresh
      expect(BulkTask.all).to have(3).items
    end
    
    it 'assigns a relative directory' do
      BulkTask.refresh
      expect(Pathname(BulkTask.first.directory)).to be_relative
    end

    it 'does not create duplicate BulkTasks' do
      BulkTask.new(:directory => File.join(APP_CONFIG.batch_dir, 'test1')).save
      BulkTask.refresh
      expect(BulkTask.all).to have(3).items
    end
  end

  describe '.reset!' do
    it 'deletes assets' do
      subject.stub(:delete_assets!)
      expect(subject).to receive :delete_assets!
      subject.reset!
    end
    
    it 'sets status to new' do
      subject.status = 'ingested'
      subject.reset!
      expect(subject.status).to eq 'new'
    end
  end

  describe '.review_assets!' do
    it 'reviews all assets' do
      GenericAsset.stub(:ingest_from_csv).with(subject.absolute_path) { assets }
      subject.ingest!
      subject.review_assets!
      subject.assets.each { |a| expect(a).to be_reviewed }
    end
    
    it 'raises an error if there are no assets' do
      expect{ subject.review_assets! }.to raise_error 
    end
  end

  describe '.enqueue' do
    it 'raises an error when already processing' do
      subject.status = 'processing'
      expect{subject.enqueue}.to raise_error
    end
    it 'raises an error when already ingested' do
      subject.status = 'ingested'
      expect{subject.enqueue}.to raise_error
    end
    it 'sets status to :processing' do
      subject.enqueue
      expect(subject.status).to eq 'processing'
    end
  end

  describe '.ingest!' do
    before do
      GenericAsset.stub(:ingest_from_csv).with(subject.absolute_path) { assets }
    end

    it 'raises an error when already ingested' do
      subject.status = 'ingested'
      expect{subject.ingest!}.to raise_error
    end
    it 'ingests items' do
      expect(subject.ingest!).to be_true
      expect(subject.asset_ids).to eq pids
    end

    context 'with errors' do
      before do
        GenericAsset.stub(:ingest_from_csv).with(subject.absolute_path).and_raise(error)
      end

      let(:error) { OregonDigital::CsvBulkIngestible::CsvBatchError.new(['title'], ['blah', 'blah2', 'blah3'], ['/path/to/file.tif', 'path/to/file2.tif'] ) }
      
      it 'raises CsvBatchError' do
        expect{ subject.ingest! }.to raise_error OregonDigital::CsvBulkIngestible::CsvBatchError
      end
      
      it 'has errors' do
        begin; subject.ingest!; rescue OregonDigital::CsvBulkIngestible::CsvBatchError => e; end
        expect(subject.bulk_errors[:field]).to eq error.field_errors
        expect(subject.bulk_errors[:value]).to eq error.value_errors
        expect(subject.bulk_errors[:file]).to eq error.file_errors
      end
      it 'has failed status' do
        begin; subject.ingest!; rescue OregonDigital::CsvBulkIngestible::CsvBatchError => e; end
        expect(subject.status).to eq 'failed'
      end
    end
  end

  describe 'metadata validation' do
    context 'when receiving valid assets' do
      before do
        GenericAsset.stub(:assets_from_csv).with(subject.absolute_path) { assets }
      end

      describe 'queued validation' do
        it 'sets status to :validating' do
          subject.queue_validation
          expect(subject.status).to eq 'validating'
        end
      end

      it 'sets status to :validated' do
        subject.validate_metadata
        expect(subject.status).to eq 'validated'
      end
    end
    
    context 'when recieving an error' do
      let(:error) { OregonDigital::CsvBulkIngestible::CsvBatchError.new(['title'], ['blah', 'blah2', 'blah3'], ['/path/to/file.tif', 'path/to/file2.tif'] ) }

      before do
        GenericAsset.stub(:assets_from_csv).with(subject.absolute_path).and_raise(error)
      end

      it 'handles errors' do
        expect{ subject.validate_metadata }.not_to raise_error
      end
      it 'sets status to :invalid' do
        subject.validate_metadata
        expect(subject.status).to eq 'invalid'
      end
      it 'sets bulk_errors with errors recieved' do
        subject.validate_metadata
        expect(subject.bulk_errors[:field]).to eq ['title']
        expect(subject.bulk_errors[:value]).to eq ['blah', 'blah2', 'blah3']
        expect(subject.bulk_errors[:file]).to eq ['/path/to/file.tif', 'path/to/file2.tif']
      end
    end
  end

  describe 'status inquirers' do
    it 'responds to valid statuses' do
      [:new?, :validating?, :invalid?, :validated?, :processing?, :ingested?, :reviewed?, :deleted?, :failed?].each do |status|
        expect(subject).to respond_to status
      end
    end
  end

  describe '.delete_assets!' do
    before do
      subject.asset_ids = pids
      subject.status = 'ingested'
      subject.delete_assets!
    end

    it 'removes asset_ids' do
      expect(subject.asset_ids).to be_nil
    end

    it 'deletes objects in asset_ids' do
      pids.each do |pid|
        expect(GenericAsset.find(:pid => pid)).to be_empty
      end
    end

    it 'sets status to :deleted' do
      expect(subject.status).to eq 'deleted'
    end

    it 'returns current status when there are no assets' do
      subject.asset_ids = nil
      expect(subject.delete_assets!).to eq subject.status
    end
  end

  context 'with bag batch' do
    before do
      Dir.stub(:glob).with(File.join(subject.absolute_path, '*.csv')).and_return([])
    end

    it 'has bag type' do
      expect(subject.type).to eq :bag
    end
    
    describe 'ingesting' do
      before do
        GenericAsset.stub(:bulk_ingest_bags).with(subject.absolute_path) { assets }
        subject.ingest!
      end

      it 'ingests items' do
        expect(subject.asset_ids).to eq pids
      end
    end
  end
end
