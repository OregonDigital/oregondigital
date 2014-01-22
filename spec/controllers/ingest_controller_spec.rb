require 'spec_helper'

# NOTE: This is slightly fragile now in order to simplify testing.  If the
# ingest map changes for some reason, the tests may need to be updated to
# either stub the map as a whole or else to traverse the real map instead of
# hard-code attributes.
describe IngestController do
  let(:new_asset) { GenericAsset.new }
  let(:ds_new) { new_asset.descMetadata }
  let(:existing_asset) { GenericAsset.new }
  let(:ds_exist) { existing_asset.descMetadata }
  let(:form) { Metadata::Ingest::Form.new }

  # This is ugly but it mimics exactly what Rails params look like
  let(:attrs) do
    {
      "titles_attributes" => {
        "0" => {"type" => "title", "value" => "test title", "internal" => "", "_destroy" => "false"}
      },
      "subjects_attributes" => {
        "0" => {"type" => "subject", "value" => "foo", "internal" => "", "_destroy" => "false"},
        "1" => {"type" => "subject", "value" => "bar", "internal" => "", "_destroy" => "false"}
      }
    }
  end

  before(:each) do
    # Stub resources so we can make assertions on what the controller sees, avoid AF hits, etc
    Metadata::Ingest::Form.stub(:new => form)
    GenericAsset.stub(:new => new_asset)
    new_asset.stub(:save)
    new_asset.stub(:save!)
    GenericAsset.stub(:find).with("1").and_return(existing_asset)
    existing_asset.stub(:save)
    existing_asset.stub(:save!)
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
      for group in form.groups
        expect(form).to receive(:"build_#{group}").once
      end
      get :new
    end

    it "shouldn't build empty associations for groups which have data" do
      # Add a single empty object to each group
      for group in form.groups
        form._build_group(group, {})
      end

      # Neither builder should be called
      for group in form.groups
        expect(form).not_to receive(:"build_#{group}")
      end
      get :new
    end

    it "should assign an uploader" do
      get :new
      assigns(:upload).should be_kind_of(IngestFileUpload)
    end
  end

  describe "#edit" do
    before(:each) do
      existing_asset.title = "Title"
      existing_asset.descMetadata.subject = [
        "http://id.loc.gov/authorities/subjects/sh85050282",
        "http://id.loc.gov/authorities/subjects/sh96005121"
      ]
      existing_asset.descMetadata.created = Date.today.to_s

      get :edit, id: 1
    end

    context "form" do
      subject { form }

      it "should have four associations with data" do
        expect(subject.associations.select {|assoc| !assoc.blank?}.length).to eq(4)
      end

      it "should have a single title" do
        expect(subject.titles.length).to eq(1)
      end

      it "should have the correct title" do
        expect(subject.titles.first).to eq(Metadata::Ingest::Association.new(
          group: "title",
          type: "title",
          value: "Title",
          internal: nil,
        ))
      end

      it "should have two subjects" do
        expect(subject.subjects.length).to eq(2)
      end

      it "should have the correct subjects" do
        expect(subject.subjects[0]).to eq(Metadata::Ingest::Association.new(
          group: "subject",
          type: "subject",
          value: "http://id.loc.gov/authorities/subjects/sh85050282",
          internal: nil,
        ))
        expect(subject.subjects[1]).to eq(Metadata::Ingest::Association.new(
          group: "subject",
          type: "subject",
          value: "http://id.loc.gov/authorities/subjects/sh96005121",
          internal: nil,
        ))
      end
    end

    it "should assign an uploader" do
      get :edit, id: 1
      assigns(:upload).should be_kind_of(IngestFileUpload)
    end
  end

  describe "#create" do
    it_should_behave_like "an ingest controller uploader", :create

    it "should set single-value attributes to a scalar value" do
      expect(ds_new).to receive(:title=).with("test title")
      post :create, :metadata_ingest_form => attrs
    end

    it "should set multiple-value attributes to arrays" do
      expect(ds_new).to receive(:subject=).with(["foo", "bar"])
      post :create, :metadata_ingest_form => attrs
    end

    it "shouldn't set anything on empty attributes" do
      attrs["titles_attributes"]["0"]["type"] = ""
      attrs["titles_attributes"]["0"]["value"] = ""
      expect(ds_new).not_to receive(:title=)
      post :create, :metadata_ingest_form => attrs
    end

    it "should use the internal value if one is sent" do
      attrs["titles_attributes"]["0"]["internal"] = "internal"
      expect(ds_new).to receive(:title=).with("internal")
      post :create, :metadata_ingest_form => attrs
    end

    it "should create a new asset" do
      expect(new_asset).to receive(:save).once
      post :create, :metadata_ingest_form => attrs
    end

    it "shouldn't try to modify the asset if the form isn't valid" do
      form.stub(:valid? => false)
      expect(new_asset).not_to receive(:save)
      expect(new_asset).not_to receive(:save!)
      expect(ds_new).not_to receive(:subject=)
      expect(ds_new).not_to receive(:title=)
      post :update, id: 1, metadata_ingest_form: attrs
    end
  end

  describe "#update" do
    it_should_behave_like "an ingest controller uploader", :update

    it "should modify the existing asset" do
      expect(ds_exist).to receive(:subject=).with(["foo", "bar"])
      post :update, id: 1, metadata_ingest_form: attrs
    end

    it "should save the existing asset" do
      expect(existing_asset).to receive(:save).once
      post :update, id: 1, metadata_ingest_form: attrs
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
      post :update, id: pid, metadata_ingest_form: attrs
      asset = GenericAsset.find(pid)
      rdf = asset.descMetadata.graph
      expect(rdf).to have_statement(unknown_statement)
    end

    it "should override data" do
      existing_asset.descMetadata.subject = ["foo", "bar"]
      attrs["subjects_attributes"] = {
        "0" => {"type" => "subject", "value" => "FOO", "internal" => "", "_destroy" => "false"}
      }
      expect(ds_exist).to receive(:subject=).with("FOO")
      post :update, id: 1, metadata_ingest_form: attrs
    end

    it "should remove data properly when blank items are submitted" do
      # This is a tricky case - by default, if there's no data for a group,
      # it won't be sent to the object, so removals are only handled well
      # when a single removal happens....
      existing_asset.descMetadata.subject = ["foo", "bar"]
      attrs["subjects_attributes"].each {|index, data| data["_destroy"] = "1"}

      expect(ds_exist).to receive(:subject=).with(nil)
      post :update, id: 1, metadata_ingest_form: attrs
    end

    it "shouldn't try to modify the asset if the form isn't valid" do
      form.stub(:valid? => false)
      expect(existing_asset).not_to receive(:save)
      expect(existing_asset).not_to receive(:save!)
      expect(ds_exist).not_to receive(:subject=)
      expect(ds_exist).not_to receive(:title=)
      post :update, id: 1, metadata_ingest_form: attrs
    end
  end
end
