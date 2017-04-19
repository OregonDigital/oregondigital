require 'spec_helper'

describe OregonDigital::OAI::Model::ActiveFedoraWrapper do
  context "when initiated with a generic asset" do
    subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit=>10)}
    let(:collection_1) do
      f = FactoryGirl.build(:generic_collection)
      f.title = "My wonderful launderette"
      f.save
      f
    end
    let(:generic_asset_1) do
      f = FactoryGirl.build(:generic_asset)
      f.descMetadata.set = collection_1
      f.descMetadata.primarySet = collection_1
      f.save
      f
    end
    let(:generic_asset_2) do
      f = FactoryGirl.build(:generic_asset)
      f.descMetadata.set = collection_1
      f.descMetadata.primarySet = collection_1
      f.save
      f
    end
    let(:generic_asset_3) do
      f = FactoryGirl.create(:generic_asset)
      f.save
      f
    end
    let(:generic_asset_4) do
      f = FactoryGirl.create(:generic_asset)
      f.descMetadata.set = collection_1
      f.descMetadata.primarySet = collection_1
      f.read_groups = f.read_groups - ["public"]
      f.read_groups |= ["University-of-Oregon"]
      f.save
      f
    end
    let(:generic_asset_5) do
      f = FactoryGirl.create(:generic_asset)
      f.save
      f
    end

    let(:generic_asset_6) do
      f = FactoryGirl.create(:generic_asset)
      f.save
      f
    end

    before(:each) do
      generic_asset_1
      sleep(1)
      generic_asset_2
      generic_asset_1.reload
      generic_asset_2.reload
      expect(generic_asset_1.modified_date).not_to eq generic_asset_2.modified_date
    end
    describe "#find" do
      context "when given :all" do
        it "should return all records" do
          expect(subject.find(:all).length).to eq 2
        end
      end
      context "when given a limit" do
        let(:assets) { ActiveFedora::SolrService.query("active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection AND (read_access_group_ssim:public OR workflow_metadata__destroyed_ssim:true)", :sort => "system_modified_dtsi desc", :fl=> "id, system_modified_dtsi") }
        before do
          generic_asset_3.descMetadata.set = collection_1
          generic_asset_3.descMetadata.primarySet = collection_1
          generic_asset_3.save
          generic_asset_1.descMetadata.title = ["one"]
          generic_asset_1.save
          generic_asset_2.descMetadata.title = ["two"]
          generic_asset_2.save
        end
        subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 1)}
        it "should return only that many" do
          expect(subject.find(:all).records.length).to eq 1
        end
        it "should provide a token" do
          expect(subject.find(:all).token.last).to eq 1
        end
        it "should provide a usable token" do
          first_result = subject.find(:all, :metadata_prefix => 'oai_dc')
          expect(first_result.records.first.pid).to eq assets[0]["id"]
          token = first_result.token.send(:encode_conditions)
          middle_result = subject.find(:all, :resumption_token => token)
          expect(middle_result.records.first.pid).to eq assets[1]["id"]
          expect(middle_result).to respond_to(:token)
        end
      end
      context "but at the end of the set" do
        let(:assets) { ActiveFedora::SolrService.query("active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection AND (read_access_group_ssim:public OR workflow_metadata__destroyed_ssim:true) AND desc_metadata__primarySet_teim:[ * TO * ]", :sort => "system_modified_dtsi desc", :fl=> "id, system_modified_dtsi") }

        before do
          generic_asset_5.descMetadata.title = ["five"]
          generic_asset_5.descMetadata.primarySet = collection_1
          generic_asset_5.save
          generic_asset_6.descMetadata.title = ["six"]
          generic_asset_6.save
          sleep(1)
          generic_asset_1.descMetadata.title = ["one"]
          generic_asset_1.save
          generic_asset_2.descMetadata.title = ["two"]
          generic_asset_2.save
        end
        subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 2)}
        it "should stop providing tokens at the end of the results" do
          first_result = subject.find(:all, :metadata_prefix => 'oai_dc')
          token = first_result.token.send(:encode_conditions)
          second_result = subject.find(:all, :resumption_token => token)
          expect(second_result.respond_to? :token).to be false
        end
      end
      context "when there are no results for one chunk" do
        let(:assets) { ActiveFedora::SolrService.query("active_fedora_model_ssi:* -active_fedora_model_ssi:GenericCollection AND (read_access_group_ssim:public OR workflow_metadata__destroyed_ssim:true) AND desc_metadata__primarySet_teim:[ * TO * ]", :sort => "system_modified_dtsi desc", :fl=> "id, system_modified_dtsi") }
        let(:ga1_obj) { {"id"=>generic_asset_1.pid} }
        let(:ga2_obj) { {"id"=>generic_asset_2.pid} }
        let(:subset) { assets.slice(0,2) }
        before do
          generic_asset_3.descMetadata.title = ["three"]
          generic_asset_3.descMetadata.primarySet = RDF::URI("http://oregondigital.org/resource/oregondigital:badset")
          generic_asset_3.save
          generic_asset_5.descMetadata.title = ["five"]
          generic_asset_5.descMetadata.primarySet = RDF::URI("http://oregondigital.org/resource/oregondigital:badset")
          generic_asset_5.save
          generic_asset_6.descMetadata.title = ["six"]
          generic_asset_3.descMetadata.primarySet = RDF::URI("http://oregondigital.org/resource/oregondigital:badset")
          generic_asset_6.save
        end
        subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :qry_rows =>2, :limit => 2)}
        it "should try again with the next chunk" do
          expect(subset).not_to include(ga1_obj, ga2_obj)
          result = subject.find(:all,  :metadata_prefix=>'oai_dc')
          expect(result.records).not_to eq 0
        end
      end

      context "when there is a restricted asset" do
        it "should not include the asset" do
          expect(subject.find(:all)).not_to include generic_asset_4
        end
      end
      context "when given a date range that ends prior to today" do
        it "should return 0 records" do
          expect(subject.find(:all, :from => "2010-01-01", :until=>"2013-12-31")).to eq nil
        end
      end
      context "when given an id" do
        it "should return that record" do
          asset_id = generic_asset_1.pid.split(":").last
          coll_id = collection_1.pid.split(":").last
          expect(subject.find("oai:oregondigital.org:#{coll_id}/#{asset_id}").title).to eq generic_asset_1.title
        end
      end
      context "when given a set" do
        it "should return records belonging to set " do
          expect(subject.find('', :set => collection_1.pid).length).to eq 2
        end
      end
    end
    describe "#earliest" do
      it "should return the earliest modified_date timestamp" do
        ga_time = generic_asset_1.modified_date.to_time(:utc)
        expect(subject.earliest).to eq ga_time.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
    describe "#latest" do
      it "should return the latest modified_date timestamp" do
        ga_time = generic_asset_2.modified_date.to_time(:utc)
        expect(subject.latest).to eq ga_time.strftime("%Y-%m-%dT%H:%M:%SZ")
      end
    end
    describe "#compound objects" do
      before do
        generic_asset_2.descMetadata.primarySet.clear
        generic_asset_2.save
        generic_asset_1.od_content << generic_asset_2
        generic_asset_1.save
        generic_asset_1.reload
      end
      it "should not return a child" do
        expect(subject.find(:all)).to eq [generic_asset_1]
      end
    end
    describe "#sets" do
      let(:collection_2) do
        f = FactoryGirl.build(:generic_collection)
        f.title = "Fly, be free"
        f.save
        f
      end
      before do
        collection_1
        collection_2
        generic_asset_1.descMetadata.primarySet = RDF::URI("http://oregondigital.org/resource/" + collection_1.id)
        generic_asset_1.save
      end
      it "should return an array with only the coll that is a primary set" do
        expect(subject.sets.first.name).to eq collection_1.title
      end
    end
  end
end
