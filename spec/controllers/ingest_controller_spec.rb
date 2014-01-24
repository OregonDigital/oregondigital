require 'spec_helper'

# NOTE: This is slightly fragile now in order to simplify testing.  If the
# ingest map changes for some reason, the tests may need to be updated to
# either stub the map as a whole or else to traverse the real map instead of
# hard-code attributes.
describe IngestController do
  before(:each) do
    # Create a local form and stub .new so we can make assertions on what the controller sees
    @form = Metadata::Ingest::Form.new
    Metadata::Ingest::Form.stub(:new => @form)

    # Stub asset to avoid AF hits, create expectations, etc
    @new_asset = GenericAsset.new
    @ds_new = @new_asset.descMetadata
    @new_asset.stub(:save)
    @new_asset.stub(:save!)
    GenericAsset.stub(:new => @new_asset)

    @existing_asset = GenericAsset.new
    @ds_exist = @existing_asset.descMetadata
    @existing_asset.stub(:save)
    @existing_asset.stub(:save!)
    GenericAsset.stub(:find).with("1").and_return(@existing_asset)

    # This is ugly but it mimics exactly what Rails params look like
    @attrs = {
      "titles_attributes" => {
        "0" => {"type" => "title", "value" => "test title", "internal" => "", "_destroy" => "false"}
      },
      "subjects_attributes" => {
        "0" => {"type" => "subject", "value" => "foo", "internal" => "", "_destroy" => "false"},
        "1" => {"type" => "subject", "value" => "bar", "internal" => "", "_destroy" => "false"}
      }
    }
  end

  describe "#index" do
    # Index doesn't do much yet, so this is just a quick smoke test to verify nothing crashes
    it "works" do
      get :index
    end
  end

  describe "#new" do
    it "should assign a form variable" do
      get :new
      expect(assigns(:form)).to be_kind_of(Metadata::Ingest::Form)
    end

    it "should build an empty association for each group" do
      for group in @form.groups
        expect(@form).to receive(:"build_#{group}").once
      end
      get :new
    end

    it "shouldn't build empty associations for groups which have data" do
      # Add a single empty object to each group
      for group in @form.groups
        @form._build_group(group, {})
      end

      # Neither builder should be called
      for group in @form.groups
        expect(@form).not_to receive(:"build_#{group}")
      end
      get :new
    end
  end

  describe "#edit" do
    it "should have a form representing the asset" do
      @existing_asset.title = "Title"
      @existing_asset.descMetadata.subject = [
        "http://id.loc.gov/authorities/subjects/sh85050282",
        "http://id.loc.gov/authorities/subjects/sh96005121"
      ]

      get :edit, id: 1

      sub1 = @form.subjects.first
      sub2 = @form.subjects.last
      title = @form.titles.first

      expect(sub1.group).to eq("subject")
      expect(sub2.group).to eq("subject")
      expect(title.group).to eq("title")

      expect(sub1.type).to eq("subject")
      expect(sub2.type).to eq("subject")
      expect(title.type).to eq("title")

      expect(sub1.value).to eq("http://id.loc.gov/authorities/subjects/sh85050282")
      expect(sub2.value).to eq("http://id.loc.gov/authorities/subjects/sh96005121")
      expect(title.value).to eq("Title")

      expect(@form.titles.length).to eq(1)
      expect(@form.subjects.length).to eq(2)
    end
  end

  describe "#create" do
    it "should set single-value attributes to a scalar value" do
      expect(@ds_new).to receive(:title=).with("test title")
      post :create, :metadata_ingest_form => @attrs
    end

    it "should set multiple-value attributes to arrays" do
      expect(@ds_new).to receive(:subject=).with(["foo", "bar"])
      post :create, :metadata_ingest_form => @attrs
    end

    it "shouldn't set anything on empty attributes" do
      @attrs["titles_attributes"]["0"]["type"] = ""
      @attrs["titles_attributes"]["0"]["value"] = ""
      expect(@ds_new).not_to receive(:title=)
      post :create, :metadata_ingest_form => @attrs
    end

    it "should use the internal value if one is sent" do
      @attrs["titles_attributes"]["0"]["internal"] = "internal"
      expect(@ds_new).to receive(:title=).with("internal")
      post :create, :metadata_ingest_form => @attrs
    end

    it "should create a new asset" do
      expect(@new_asset).to receive(:save).once
      post :create, :metadata_ingest_form => @attrs
    end

    it "shouldn't try to modify the asset if the form isn't valid" do
      @form.stub(:valid? => false)
      expect(@new_asset).not_to receive(:save)
      expect(@new_asset).not_to receive(:save!)
      expect(@ds_new).not_to receive(:subject=)
      expect(@ds_new).not_to receive(:title=)
      post :update, id: 1, metadata_ingest_form: @attrs
    end
  end

  describe "#update" do
    it "should modify the existing asset" do
      expect(@ds_exist).to receive(:subject=).with(["foo", "bar"])
      post :update, id: 1, metadata_ingest_form: @attrs
    end

    it "should save the existing asset" do
      expect(@existing_asset).to receive(:save).once
      post :update, id: 1, metadata_ingest_form: @attrs
    end

    it "shouldn't modify unmapped data" do
      # We use a real object here as RDF magic happens in the saving
      # cycle as opposed to any obvious place in our code
      GenericAsset.unstub(:find)
      GenericAsset.unstub(:new)
      asset = FactoryGirl.build(:image, title: "Testing stuffs")
      unknown_statement = RDF::Statement.new(
        RDF::URI.new("subject"),
        RDF::URI.new("predicate"),
        RDF::Literal.new("object")
      )
      asset.descMetadata.graph << unknown_statement
      asset.save

      pid = asset.pid
      post :update, id: pid, metadata_ingest_form: @attrs
      asset = GenericAsset.find(pid)
      rdf = asset.descMetadata.graph
      expect(rdf).to have_statement(unknown_statement)
    end

    it "should override data" do
      @existing_asset.descMetadata.subject = ["foo", "bar"]
      @attrs["subjects_attributes"] = {
        "0" => {"type" => "subject", "value" => "FOO", "internal" => "", "_destroy" => "false"}
      }
      expect(@ds_exist).to receive(:subject=).with("FOO")
      post :update, id: 1, metadata_ingest_form: @attrs
    end

    it "should remove data properly when blank items are submitted" do
      # This is a tricky case - by default, if there's no data for a group,
      # it won't be sent to the object, so removals are only handled well
      # when a single removal happens....
      @existing_asset.descMetadata.subject = ["foo", "bar"]
      @attrs["subjects_attributes"].each {|index, data| data["_destroy"] = "1"}

      expect(@ds_exist).to receive(:subject=).with(nil)
      post :update, id: 1, metadata_ingest_form: @attrs
    end

    it "shouldn't try to modify the asset if the form isn't valid" do
      @form.stub(:valid? => false)
      expect(@existing_asset).not_to receive(:save)
      expect(@existing_asset).not_to receive(:save!)
      expect(@ds_exist).not_to receive(:subject=)
      expect(@ds_exist).not_to receive(:title=)
      post :update, id: 1, metadata_ingest_form: @attrs
    end
  end
end
