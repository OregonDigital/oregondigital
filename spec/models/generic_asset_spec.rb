require 'spec_helper'

describe GenericAsset, :resque => true do
  it_behaves_like 'a baggable item'
  it_behaves_like 'a collectible item'

  subject(:generic_asset) { FactoryGirl.build(:generic_asset) }

  it 'should initialize' do
    expect { generic_asset }.not_to raise_error
  end


  describe "load from solr" do
    context "when it's loaded from solr" do
      let(:asset) {FactoryGirl.create(:generic_asset)}
      subject {ActiveFedora::Base.load_instance_from_solr(asset.pid)}
      before do
        asset
      end
      it "should not touch Fedora" do
        expect(ActiveFedora::Relation.any_instance).not_to receive(:load_from_fedora)
        subject
      end
      it "should respond to all attributes" do
        expect(subject.title).to eq asset.title
      end
    end
  end

  describe '.save' do
    context 'when content has not been assigned' do
      it 'should not try to create derivatives' do
        generic_asset.should_not_receive(:create_derivatives)
        generic_asset.save
      end
    end
    context 'when content has been assigned' do
      before(:each) do
        file = File.open(File.join(fixture_path, 'fixture_image.jpg'), 'rb')
        generic_asset.add_file_datastream(file, :dsid => 'content')
        expect(generic_asset.content).not_to be_blank
      end
      it 'should try to create derivatives' do
        GenericAsset.any_instance.should_receive(:create_derivatives)
        generic_asset.save
      end
    end
    context "when content is returned to nil" do
      before(:each) do
        file = File.open(File.join(fixture_path, 'fixture_image.jpg'), 'rb')
        generic_asset.add_file_datastream(file, :dsid => 'content')
        generic_asset.save
        g = GenericAsset.find(generic_asset.pid)
        generic_asset.content.content = nil
      end
      it "should not try to create derivatives" do
        GenericAsset.any_instance.should_not_receive(:create_derivatives)
        generic_asset.save
      end
    end
  end

  describe "#soft_destroy" do
    before do
      # Stub current time - replace with timecop?
      @time = Time.current
      Time.stub(:current).and_return(@time)
      # Save generic asset.
      subject.save
      # Soft delete
      subject.soft_destroy
    end
    it "should be marked as destroyed" do
      expect(subject.workflowMetadata.destroyed).to eq true
    end
    it "should mark the destroyed_at time" do
      expect(subject.workflowMetadata.destroyed_at).to eq @time.iso8601
    end
  end

  describe "#undelete" do
    before do
      subject.save
    end
    context "when the item is not deleted" do
      it "should not do anything" do
        subject.undelete
        expect(subject).not_to be_soft_destroyed
      end
    end
    context "when the item is deleted" do
      before do
        subject.soft_destroy
      end
      it "should restore the item" do
        subject.undelete
        expect(subject).not_to be_soft_destroyed
      end
    end
  end

  describe "#soft_destroyed?" do
    before do
      subject.save
    end
    context "when an object is destroyed" do
      before do
        subject.soft_destroy
      end
      it "should be destroyed" do
        expect(subject).to be_soft_destroyed
      end
    end
    context "when an object is destroyed, then undestroyed" do
      before do
        subject.soft_destroy
        subject.workflowMetadata.destroyed = false
      end
      it "should not be destroyed" do
        expect(subject).not_to be_soft_destroyed
      end
      context "and then destroyed" do
        before do
          subject.soft_destroy
        end
        it "should be destroyed" do
          expect(subject).to be_soft_destroyed
        end
      end
    end
  end

  describe ".destroyed" do
    before do
      subject.title = "bla"
      subject.save
    end
    context "when an asset is destroyed" do
      before do
        subject.soft_destroy
      end
      it "should return all destroyed objects" do
        expect(subject.class.destroyed.to_a).to eq [subject]
      end
      it "should chain" do
        expect(subject.class.destroyed.where("desc_metadata__title_teim" => "test")).to eq []
        expect(subject.class.destroyed.where("desc_metadata__title_teim" => "bla")).to eq [subject]
      end
    end
    context "when an asset is not destroyed" do
      it "should not return non-destroyed objects" do
        expect(subject.class.destroyed.to_a).to eq []
      end
    end
  end

  describe '#set' do
    context "when it has an assigned set" do
      let(:collection) {FactoryGirl.create(:generic_collection)}
      let(:assigned_object) {collection}
      before(:each) do
        subject.set = assigned_object
      end

      context "by assigning it a collection object" do
        it "should return the set" do
          expect(subject.set).to eq [collection]
        end
        it "should return the set (after reload)" do
          subject.save
          subject.reload
          expect(subject.set).to eq [collection]
        end
        it "should index the rdf label" do
          expect(subject.to_solr[Solrizer.solr_name("desc_metadata__set_label", :facetable)]).to eq ["#{collection.resource.rdf_label.first}$#{collection.resource.rdf_subject.to_s}"]
        end
        it "should update the RDF label when the set is updated" do
          subject.save
          expect(subject.class.where(Solrizer.solr_name("desc_metadata__set_label", :facetable) => "#{collection.title}$#{collection.resource.rdf_subject.to_s}").length).to eq 1
          #collection.reload
          collection.title = "AnotherTitle"
          collection.save
          expect(subject.class.where(Solrizer.solr_name("desc_metadata__set_label", :facetable) => "#{collection.title}$#{collection.resource.rdf_subject.to_s}").length).to eq 1
        end
      end

      context "by assigning it a URI" do
        let(:assigned_object) {collection.resource.rdf_subject}
        it "should return the set (after reload)" do
          subject.save
          subject.reload
          expect(subject.set).to eq [collection]
        end
      end
    end
  end

  describe "fetching data" do
    let(:subject_1) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282")}
    subject(:generic_asset) do
      g = FactoryGirl.build(:generic_asset)
      g.descMetadata.lcsubject = subject_1
      g.save
      g
    end
    it "should fetch on save" do
      subject.reload
      expect(subject.descMetadata.lcsubject.first.rdf_label.first).to eq "Food industry and trade"
    end
    context "when a new object asset has a subject that is fetched" do
      let(:asset_2) {
        g = FactoryGirl.build(:generic_asset)
        g.descMetadata.lcsubject = subject_1
        g
      }
      before(:each) do
        # Stop auto reload
        GenericAsset.any_instance.stub(:queue_fetch).and_return(true)
        subject
        expect(GenericAsset.where("desc_metadata__subject_label_sim" => "Food industry and trade#{subject_1.to_s}").length).to eq 0
        asset_2.descMetadata.fetch_external
      end
      it "should set that object's label" do
        expect(asset_2.descMetadata.lcsubject.first.rdf_label.first).to eq "Food industry and trade"
      end
      it "should fix the label on other objects" do
        subject.reload
        expect(subject.descMetadata.lcsubject.first.rdf_label.first).to eq "Food industry and trade"
      end
      it "should not call fetch again when run again within 7 days" do
        expect(asset_2.descMetadata.lcsubject.first).not_to receive(:fetch)
        asset_2.descMetadata.fetch_external
      end
      it "should persist the label to solr for other objects" do
        expect(GenericAsset.where("desc_metadata__lcsubject_label_sim" => "Food industry and trade$#{subject_1.to_s}").length).to eq 1
      end
    end
  end

  describe 'indexing of deep nodes' do
    context 'when the object has a deep node with an rdf_subject' do
      let(:subject_1) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85050282")}
      let(:subject_2) {RDF::URI.new("http://id.loc.gov/authorities/subjects/sh85123395")}
      subject(:generic_asset) do
        g = FactoryGirl.build(:generic_asset)
        g.descMetadata.lcsubject = subject_1
        g.descMetadata.lcsubject.first.set_value(RDF::SKOS.prefLabel, "Test Subject")
        g.descMetadata.lcsubject.first.persist!
        g.descMetadata.lcsubject << subject_2
        g.descMetadata.lcsubject.last.set_value(RDF::SKOS.prefLabel, "Dogs")
        g.descMetadata.lcsubject.first.persist!
        g
      end
      it "should index it" do
        name = subject.solr_name('desc_metadata__lcsubject_label',:facetable)
        expect(subject.to_solr).to include name
        expect(subject.to_solr[name]).to eq ["Test Subject$#{subject_1.to_s}", "Dogs$#{subject_2.to_s}"]
      end
    end
  end

  describe 'pid assignment' do
    context 'before the object is saved' do
      it 'should be nil' do
        expect(generic_asset.pid).to be_nil
      end
    end
    context 'when a new object is saved' do
      context "when it doesn't have a pid" do
        before(:each) do
          OregonDigital::IdService.should_receive(:mint).and_call_original
          generic_asset.save
        end
        it 'should no longer be nil' do
          expect(generic_asset.pid).not_to be_nil
        end
        it 'should be a valid NOID' do
          expect(OregonDigital::IdService.valid?(generic_asset.pid)).to eq true
        end
      end
      context 'but it already has a pid' do
        subject(:generic_asset) { FactoryGirl.create(:generic_asset, :has_pid, pid: "changeme:monkeys") }
        it 'should not override the pid' do
          expect(generic_asset.pid).to eq 'changeme:monkeys'
          expect(generic_asset).to be_persisted
        end
      end
    end
  end

  describe '#compound_parent' do
    context "when it doesn't have a parent" do
      it "should return nil" do
        expect(generic_asset.compound_parent).to be_nil
      end
      it "should not be compounded" do
        expect(generic_asset).not_to be_compounded
      end
    end
    context "when it does have a parent" do
      let(:parent) {FactoryGirl.create(:generic_asset)}
      before do
        generic_asset.save
        parent.od_content << generic_asset
        parent.save
      end
      it "should return the parent" do
        expect(generic_asset.compound_parent).to eq parent
      end
      it "should be compounded" do
        expect(generic_asset).to be_compounded
      end
    end
  end


  describe '#od_content' do
    let(:asset_2) {FactoryGirl.create(:generic_asset)}
    let(:asset_3) {FactoryGirl.create(:generic_asset)}
    context "when there are no entries" do
      it "should not be a compound object" do
        expect(generic_asset).not_to be_compound
      end
      it "should not add statements to the graph" do
        expect(generic_asset).not_to be_compound
        expect(generic_asset.resource.query([nil, OregonDigital::Vocabularies::OREGONDIGITAL.contents, nil]).to_a.length).to eq 0
      end
    end
    context "when it has one asset" do
      before do
        generic_asset.od_content << asset_2
      end
      context "and it's persisted" do
        before do
          generic_asset.save
        end
        it "should be re-gettable" do
          expect(GenericAsset.find(generic_asset.pid).od_content.to_a.map(&:references)).to eq [[asset_2]]
        end
      end
    end
    context "when appending" do
      before do
        generic_asset.od_content << asset_2
        generic_asset.od_content << asset_3
      end
      context "when appending an unsaved object" do
        it "should error" do
          expect{generic_asset.od_content << GenericAsset.new}.to raise_error
        end
      end
      it "should be gettable" do
        expect(generic_asset.od_content.to_a.map(&:references)).to eq [[asset_2], [asset_3]]
      end
      it "should index" do
        expect(generic_asset.to_solr[Solrizer.solr_name("desc_metadata__od_content_references", :symbol)]).to eq [asset_2.resource.rdf_subject.to_s, asset_3.resource.rdf_subject.to_s]
      end
      it "should be a compound object" do
        expect(generic_asset).to be_compound
      end
      context "and it's persisted" do
        let(:asset_4) {FactoryGirl.create(:generic_asset)}
        before do
          generic_asset.save
        end

        it "should store and retrieve more than two appended objects" do
          generic_asset.od_content << asset_4
          generic_asset.save
          reloaded_asset = GenericAsset.find(generic_asset.pid)
          expect(reloaded_asset.od_content.to_a.map(&:references)).to eq [[asset_2], [asset_3], [asset_4]]
        end

        it "be able to get its content back" do
          expect(GenericAsset.find(generic_asset.pid).od_content.to_a.map(&:references)).to eq [[asset_2], [asset_3]]
        end
        it "should be able to append more objects" do
          generic_asset.od_content << asset_4
          expect(generic_asset.od_content.to_a.map(&:references)).to eq [[asset_2], [asset_3], [asset_4]]
        end
      end
    end
  end
end
