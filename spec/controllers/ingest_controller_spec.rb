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
    end

    context "for a new asset" do
      before(:each) do
        # Hack groups to just two simple values
        Metadata::Ingest::Form.stub(:groups).and_return(["foo", "bar"])

        # Make sure we don't typo a method, since that's a false positive
        @build_foo = :build_foo
        @build_bar = :build_bar
      end

      it "should assign a form variable" do
        get :form
        expect(assigns(:form)).to be_kind_of(Metadata::Ingest::Form)
      end

      it "should build an empty association for each group" do
        expect(@form).to receive(@build_foo).once
        expect(@form).to receive(@build_bar).once
        get :form
      end

      it "shouldn't build empty associations for groups which have data" do
        # Add a single empty object to each group
        @form.build_foo
        @form.build_bar

        # Neither builder should be called
        expect(@form).not_to receive(@build_foo)
        expect(@form).not_to receive(@build_bar)
        get :form
      end
    end

    context "for an existing asset" do
      it "should have a form representing the asset" do
        asset = GenericAsset.new
        GenericAsset.stub(:find => asset)
        asset.title = "Title"
        asset.descMetadata.subject = [
          "http://id.loc.gov/authorities/subjects/sh85050282",
          "http://id.loc.gov/authorities/subjects/sh96005121"
        ]

        get :form, id: 1

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
  end

  describe "#save" do
    before(:each) do
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

    context "(when the form represents a new asset)" do
      before(:each) do
        # Stubbed asset to avoid AF hits, create expectations, etc
        @asset = GenericAsset.new
        @ds = @asset.descMetadata
        @asset.stub(:save)
        @asset.stub(:save!)
        GenericAsset.stub(:new => @asset)
      end

      it "should set single-value attributes to a scalar value" do
        expect(@ds).to receive(:title=).with("test title")
        post :save, :metadata_ingest_form => @attrs
      end

      it "should set multiple-value attributes to arrays" do
        expect(@ds).to receive(:subject=).with(["foo", "bar"])
        post :save, :metadata_ingest_form => @attrs
      end

      it "shouldn't set anything on empty attributes" do
        @attrs["titles_attributes"]["0"]["type"] = ""
        @attrs["titles_attributes"]["0"]["value"] = ""
        expect(@ds).not_to receive(:title=)
        post :save, :metadata_ingest_form => @attrs
      end

      it "should use the internal value if one is sent" do
        @attrs["titles_attributes"]["0"]["internal"] = "internal"
        expect(@ds).to receive(:title=).with("internal")
        post :save, :metadata_ingest_form => @attrs
      end

      it "should create a new asset" do
        expect(@asset).to receive(:save).once
        post :save, :metadata_ingest_form => @attrs
      end
    end

    context "(when the form represents an existing asset)" do
      before(:each) do
        # Stubbed asset to avoid AF hits, create expectations, etc
        @asset = GenericAsset.new
        GenericAsset.stub(:find).with("1").and_return(@asset)
        @ds = @asset.descMetadata
        @asset.stub(:save)
        @asset.stub(:save!)
      end

      it "should modify the existing asset" do
        expect(@ds).to receive(:subject=).with(["foo", "bar"])
        post :save, id: 1, metadata_ingest_form: @attrs
      end

      it "should save the existing asset" do
        expect(@asset).to receive(:save).once
        post :save, id: 1, metadata_ingest_form: @attrs
      end

      it "shouldn't modify unmapped data" do
        # We use a real object here as RDF magic happens in the saving
        # cycle as opposed to any obvious place in our code
        asset = FactoryGirl.build(:image, title: "Testing stuffs")
        unknown_statement = RDF::Statement.new(
          RDF::URI.new("subject"),
          RDF::URI.new("predicate"),
          RDF::Literal.new("object")
        )
        asset.descMetadata.graph << unknown_statement
        asset.save

        pid = asset.pid
        GenericAsset.unstub(:find)
        post :save, id: pid, metadata_ingest_form: @attrs
        asset = GenericAsset.find(pid)
        rdf = asset.descMetadata.graph
        expect(rdf).to have_statement(unknown_statement)
      end

      it "should override data" do
        @asset.descMetadata.subject = ["foo", "bar"]
        @attrs["subjects_attributes"] = {
          "0" => {"type" => "subject", "value" => "FOO", "internal" => "", "_destroy" => "false"}
        }
        expect(@ds).to receive(:subject=).with("FOO")
        post :save, id: 1, metadata_ingest_form: @attrs
      end

      it "should remove data properly when blank items are submitted" do
        # This is a tricky case - by default, if there's no data for a group,
        # it won't be sent to the object, so removals are only handled well
        # when a single removal happens....
        @asset.descMetadata.subject = ["foo", "bar"]
        @attrs.delete("subjects_attributes")
        pending "Umm... hmm.  Now how do I solve this?"

        expect(@ds).to receive(:subject=).with("")
        post :save, id: 1, metadata_ingest_form: @attrs
      end
    end
  end
end
