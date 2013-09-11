require 'spec_helper'

describe GenericAsset do
  it_behaves_like 'a baggable item'

  subject(:generic_asset) {GenericAsset.new}

  it "should initialize" do
    expect{generic_asset}.not_to raise_error
  end
  describe "pid assignment" do
    context "before the object is saved" do
      it "should be a filler PID" do
        expect(generic_asset.pid).to eq "__DO_NOT_USE__"
      end
    end
    context "when a new object is saved" do
      context "when it doesn't have a pid" do
        before(:each) do
          OregonDigital::IdService.should_receive(:mint).and_call_original
          generic_asset.save
        end
        it "should no longer be a filler PID" do
          expect(generic_asset.pid).not_to eq "__DO_NOT_USE__"
        end
        it "should be a valid NOID" do
          expect(OregonDigital::IdService.valid?(generic_asset.pid)).to eq true
        end
      end
      context "but it already has a pid" do
        subject(:generic_asset) {GenericAsset.new(:pid => "changeme:monkeys")}
        before(:each) do
          generic_asset.save
        end
        it "should not override the pid" do
          expect(generic_asset.pid).to eq "changeme:monkeys"
          expect(generic_asset).to be_persisted
        end
      end
    end
  end

  describe '.collections' do
    before do
      @coll = GenericCollection.new(:title => "Bar foo")
      @coll.save
      @coll2 = GenericCollection.new(:title => "Foo bar")
      @coll2.save
    end
    before(:each) do
      generic_asset.descMetadata.set = [@coll.pid]
      generic_asset.save
    end
    it 'should return objects for all collections in item metadata' do
      generic_asset.collections.should == [@coll]
    end
    it "should be able to return multiple objects" do
      generic_asset.descMetadata.set = [@coll.pid, @coll2.pid]
      generic_asset.save
      generic_asset.collections(true).should == [@coll, @coll2]
    end
  end
end
