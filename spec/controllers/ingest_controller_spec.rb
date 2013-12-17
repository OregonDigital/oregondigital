require 'spec_helper'

describe IngestController do
  describe "#index" do
    # Index doesn't do much yet, so this is just a quick smoke test to verify nothing crashes
    it "works" do
      get :index
    end
  end

  describe "#form" do
    before(:each) do
      # Create a local form and stub .new so we can make assertions on what the controller sees
      @form = Metadata::Ingest::Form.new
      Metadata::Ingest::Form.stub(:new => @form)

      # Hack groups to just two simple values
      Metadata::Ingest::Form.stub(:groups).and_return(["foo", "bar"])

      # Make sure we don't typo a should_not_receive, since that's a false positive
      @build_foo = :build_foo
      @build_bar = :build_bar
    end

    it "should assign a form variable" do
      get :form
      expect(assigns(:form)).to be_kind_of(Metadata::Ingest::Form)
    end

    it "should build an empty association for each group" do
      @form.should_receive(@build_foo).once
      @form.should_receive(@build_bar).once
      get :form
    end

    it "shouldn't build empty associations for groups which have data" do
      # Add a single empty object to each group
      @form.build_foo
      @form.build_bar

      # Neither builder should be called
      @form.should_not_receive(@build_foo)
      @form.should_not_receive(@build_bar)
      get :form
    end
  end
end
