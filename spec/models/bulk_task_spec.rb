require 'spec_helper'

describe BulkTask do

  before do
    Dir.stub(:glob).and_call_original
    APP_CONFIG.stub(:batch_dir).and_return(Rails.root.join("tmp", "bags"))
  end
  
  subject { BulkTask.new :directory => 'bulkloads' }

  describe 'bulk bag ingest', :resque => true do
    before do
      ActiveFedora::Rdf::Resource.any_instance.stub(:fetch).and_return(true)
    end
    let(:asset) do
      a = GenericAsset.new
      graph = RDF::Graph.load(Rails.root.join("spec", "fixtures", "fixture_triples.nt"))
      a.resource << graph
      a.save
      a.stub(:bag_path).and_return(Rails.root.join("tmp", "bags", "bulkloads", "1").to_s)
      a
    end
    let(:bag) do
      asset.write_bag
      asset.bag
    end
    before do
      MIME::Types.stub(:[]).and_call_original
      extensions = ["nt"]
      results = double()
      results.stub(:extensions).and_return(extensions)
      MIME::Types.stub(:[]).with("application/n-triples").and_return([results])
      bag
      Dir.stub(:glob).with(Rails.root.join("tmp", "bags")).and_return(Rails.root.join("tmp", "bags", "bulkloads"))
    end
    after do
      FileUtils.rm_rf(Rails.root.join("tmp", "bags", "bulkloads"))
    end

    subject { BulkTask.create(:directory => "bulkloads") }

    describe "creation" do
      it "creates 1 child" do
        expect(subject.reload.bulk_task_children.count).to eq 1
      end
      it "doesn't recreate children" do
        subject.save
        subject.save
        expect(subject.reload.bulk_task_children.count).to eq 1
      end
    end

    describe "#refresh" do
      context "when there is a new bag" do
        before do
          subject.save
          FileUtils.cp_r(bag.bag_dir, Pathname.new(bag.bag_dir).dirname.join("2"))
          subject.reload
          BulkTask.find(subject.id).refresh
        end
        it "should create a child for it" do
          expect(subject.reload.bulk_task_children.count).to eq 2
        end
      end
    end

    describe "#ingest!" do
      let(:setup) {}
      before do
        setup
        subject.ingest!
        subject.reload
      end
      context "when there are no items" do
        let(:setup) do
          FileUtils.rm_rf(Rails.root.join("tmp", "bags", "bulkloads", "1"))
        end
        it "should be new" do
          expect(subject).to be_new
        end
      end
      context "when everything is good" do
        it "should create one asset" do
          expect(subject.assets.size).to eq 1
        end
        it "should be ingested" do
          expect(subject).to be_ingested
        end
      end
      context "when an asset fails to save" do
        let(:bad_asset) do
          g = GenericAsset.new
          g.descMetadata.lcsubject = ::RDF::URI("http://baduri.com")
          g
        end
        let(:setup) do
          BulkTaskChild.any_instance.stub(:build_bag_asset).and_return(bad_asset)
        end
        it "should have no assets" do
          expect(subject.assets.size).to eq 0
        end
        it "should have stored the error" do
          expect(subject.bulk_task_children.first.result[:error][:message]).to eq "Term not in controlled vocabularies: http://baduri.com"
        end
        it "should be in errored status" do
          expect(subject).to be_errored
        end
      end
    end

    describe '#type' do
      it "should be a bag" do
        expect(subject.type).to eq :bag
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

    it 'is idempotent' do
      BulkTask.refresh
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
end
