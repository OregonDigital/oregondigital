require 'spec_helper'

describe OregonDigital::RewriteGenerator do

  describe ".call" do
    subject {OregonDigital::RewriteGenerator.call}
    before do
      OregonDigital::RewriteGenerator.any_instance.stub(:output_directory).and_return(Rails.root.join("tmp"))
    end
    let(:file_path) {Rails.root.join("tmp", "hydra_rewrite_rules.conf")}
    after do
      if File.exist?(file_path)
        FileUtils.rm(file_path)
      end
    end
    context "when there are replaces records" do
      context "when there is an object with no replaces attribute" do
        let(:asset) {FactoryGirl.create(:generic_asset)}
        before do
          subject
        end
        it "should not create a rewrite conf file" do
          expect(File.exist?(file_path)).not_to be_true
        end
      end
      context "when there is an object with a replaces attribute" do
        let(:asset) do
          a = FactoryGirl.build(:generic_asset)
          a.descMetadata.replacesUrl = replaces
          a.save!
          a
        end
        let(:replaces) {"http://oregondigital.org/u?bracero,62"}
        before do
          asset
          subject
        end
        it "should create a rewrite conf file" do
          expect(File.exist?(file_path)).to be_true
          strings = OregonDigital::RewriteGenerator.new.replace_strings
          expect(strings.length).to eq 2
          expect(File.read(file_path)).to eq strings.first+"\n"+strings.last+"\n"
        end
      end
    end
    context "when there are no replaces records" do
      before do
        subject
      end
      it "should not create a rewrite conf file" do
        expect(File.exist?(file_path)).not_to be_true
      end
    end

  end


  describe "#replaces_hash" do
    subject {OregonDigital::RewriteGenerator.new.replaces_hash}
    context "when there are no replaces records" do
      it "should be empty" do
        expect(subject).to eq({})
      end
    end
    context "when there is an object" do
      let(:asset) {FactoryGirl.create(:generic_asset)}
      before do
        asset
      end
      context "with no replaces attribute" do
        it "should be empty" do
          expect(subject).to eq({})
        end
      end
      context "with a replaces attribute" do
        let(:replaces) {"http://oregondigital.org/u?bracero,62"}
        let(:asset) do
          a = FactoryGirl.build(:generic_asset)
          a.descMetadata.replacesUrl = replaces
          a.save!
          a
        end
        context "which is missing a slash" do
          it "should be a hash with that attribute" do
            expect(subject).to eq({asset.pid => "/bracero,62"})
          end
        end
        context "which has the slash" do
          let(:replaces) {"http://oregondigital.org/u?/bracero,62"}
          it "should return appropriately" do
            expect(subject).to eq({asset.pid => "/bracero,62"})
          end
        end
      end
    end
  end

  describe "#replace_strings" do
    subject {OregonDigital::RewriteGenerator.new.replace_strings}

    context "when there is an object with a replaces attribute" do
      let(:asset) do
        a = FactoryGirl.build(:generic_asset)
        a.descMetadata.replacesUrl = replaces
        a.save!
        a
      end
      let(:replaces) {"http://oregondigital.org/u?bracero,62"}
      before do
        asset
      end
      it "should return a rewrite string" do
        expect(subject.first).to eq "if ($request_uri = /cdm4/item_viewer.php?CISOROOT=/bracero&CISOPTR=62&CISOBOX=1&REC=1 ) { rewrite ^ /catalog/#{asset.pid}? permanent; }"
      end
    end
  end
end
