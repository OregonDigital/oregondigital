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
    end
    let(:generic_asset_4) do
      f = FactoryGirl.create(:generic_asset)
      f.descMetadata.set = collection_1
      f.descMetadata.primarySet = collection_1
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
        before do
          sleep(1)
          generic_asset_3
          generic_asset_3.descMetadata.set = collection_1
          generic_asset_3.descMetadata.primarySet = collection_1
          generic_asset_3.save
        end
        subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 1)}
        it "should return only that many" do
          expect(subject.find(:all).records.length).to eq 1
        end
        it "should provide a token" do
          expect(subject.find(:all).token.last).to eq 1
        end
        it "should provide a usable token" do
          token = subject.find(:all, :metadata_prefix => 'oai_dc').token.send(:encode_conditions)
          middle_result = subject.find(:all, :resumption_token => token)
          expect(middle_result.records).to eq [generic_asset_2]
          expect(middle_result).to respond_to(:token)
          expect(subject.find(:all, :resumption_token => middle_result.token.send(:encode_conditions))).to eq [generic_asset_1]
        end
        context "but at the end of the set" do
          subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 2)}
          it "should stop providing tokens at the end of the results" do
            token = subject.find(:all, :metadata_prefix => 'oai_dc').token.send(:encode_conditions)# this is the first set, first token
            second_result = subject.find(:all, :resumption_token => token)#second set. should not have a token
            expect(second_result).not_to respond_to(:token)
          end
        end
        context "when there are no results for one chunk" do
          before do

            generic_asset_3.descMetadata.primarySet.delete
            generic_asset_3.save
            generic_asset_4.read_groups = generic_asset_4.read_groups - ["public"]
            generic_asset_4.read_groups |= ["University-of-Oregon"]
            generic_asset_4.save

            generic_asset_1.descMetadata.primarySet.delete
            generic_asset_1.save
            generic_asset_2.descMetadata.primarySet.delete
            generic_asset_2.save

          end
          it "should try again with the next chunk" do
            subject {OregonDigital::OAI::Model::ActiveFedoraWrapper.new(GenericAsset, :limit => 2)}
            result = subject.find(:all, :metadata_prefix=>'oai_dc')
            expect(result.records).to include generic_asset_1
          end
        end
      end
      context "when there is a restricted asset" do
        before do
          generic_asset_4.read_groups = generic_asset_4.read_groups - ["public"]
          generic_asset_4.read_groups |= ["University-of-Oregon"]
          generic_asset_4.save
        end
        it "should not include the asset" do
          expect(subject.find(:all)).not_to include generic_asset_4
        end
      end
      context "when given a date range that ends prior to today" do
        it "should return 0 records" do
          expect(subject.find(:all, :from => "2010-01-01", :until=>"2013-12-31").length).to eq 0
        end
      end
      context "when given an id" do
        it "should return that record" do
          expect(subject.find(generic_asset_1.pid).title).to eq generic_asset_1.title
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
