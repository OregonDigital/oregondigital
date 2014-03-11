require 'spec_helper'

$pid_counter = 0
describe "(Ingest Form)" do
  let(:subject1) { "http://id.loc.gov/authorities/subjects/sh2007009834" }
  let(:label1) { "Canned foods industry--Accidents" }
  let(:subject2) { "http://id.loc.gov/authorities/subjects/sh85050282" }
  let(:label2) { "Food industry and trade" }
  let(:admin) {FactoryGirl.create(:admin)}

  before(:each) do
    capybara_login(admin)

    # Ensure ingested objects create predictable and unique pids
    OregonDigital::IdService.stub(:namespace).and_return("spec-feature-ingestform")
    OregonDigital::IdService.stub(:next_id) do
      $pid_counter += 1
      @pid = OregonDigital::IdService.namespaceize($pid_counter)
    end

    # Pre-load a couple RDF subject labels
    for (uri, label) in { subject1 => label1, subject2 => label2 }
      s = OregonDigital::ControlledVocabularies::Subject.new(uri)
      s.set_value(RDF::SKOS.prefLabel, label)
      s.persist!
    end
  end

  def visit_edit_form_url(pid)
    visit("/ingest/#{pid}/edit")
    expect(page).to have_selector("input[type=submit]")
  end

  def mark_as_reviewed
    # Modify the object to be public
    img = GenericAsset.find(@pid)
    img.read_groups = ["public"]
    img.save!

    # set object reviewed
    img.review!
  end

  context "when ingesting a new object" do
    context "and the form is invalid" do
      before(:each) do
        visit_ingest_url
        fill_in_ingest_data("description", "description", "")
      end

      it "doesn't store anything in Fedora" do
        click_the_ingest_button
        expect(ActiveFedora::Base.all.count).to eq(0)
      end

      it "doesn't require an attached file to be re-uploaded" do
        submit_ingest_form_with_upload(:pdf)
        expect(page).to have_content("You do not need to redo the upload unless you want to use a different file")
        fill_in_ingest_data("description", "description", "This is valid now")
        click_the_ingest_button
        asset = GenericAsset.find(@pid)
        expect(asset.content.content == IO.binread(upload_path(:pdf))).to be_true
      end
    end

    context "with simple user-supplied data" do
      before(:each) do
        visit_ingest_url
        fill_out_dummy_data
        click_the_ingest_button
      end

      it "should succeed" do
        expect(page).to have_content("Ingested new object")
      end

      it "should show the correct data on the edit form" do
        visit_edit_form_url(@pid)
        expect(page).to include_ingest_fields_for("title", "title", "Asset Title")
        expect(page).to include_ingest_fields_for("date", "created", "2014-01-07")
        expect(page).to include_ingest_fields_for("description", "description", "This is an asset")
      end

      it "should show the correct data on the catalog page" do
        visit(catalog_path(@pid))
        expect(page.status_code).to eq(200)
        expect(page).to have_content("Asset Title")
        expect(page).to have_content("2014-01-07")
        expect(page).to have_content("This is an asset")
      end
    end

    context "with multiple items in the same group", :js => true do
      before(:each) do
        visit_ingest_url

        fill_in_ingest_data("title", "title", "Title 1")
        click_link "Add title"
        fill_in_ingest_data("title", "title", "Title 2", 1)

        fill_in_ingest_data("date", "created", "2014-03-07")
        click_link "Add date"
        fill_in_ingest_data("date", "modified", "2014-03-08", 1)
        click_the_ingest_button
      end

      it "succeed" do
        expect(page).to have_content("Ingested new object")
      end

      it "should store all the metadata properly" do
        asset = GenericAsset.find(@pid)
        expect(asset.descMetadata.title).to eq(["Title 1", "Title 2"])
        expect(asset.descMetadata.created).to eq(["2014-03-07"])
        expect(asset.descMetadata.modified).to eq(["2014-03-08"])
      end
    end

    context "with a file upload" do
      before(:each) do
        visit_ingest_url
        fill_in_ingest_data("title", "title", "Asset Title")
        submit_ingest_form_with_upload(:pdf)
        @asset = GenericAsset.find(@pid, cast: true)
      end

      it "saves uploaded files on new assets" do
        expect(@asset.content.content == IO.binread(upload_path(:pdf))).to be_true
      end

      it "overwrites asset data with uploaded files" do
        visit_edit_form_url(@pid)
        submit_ingest_form_with_upload(:jpg)
        expect(@asset.content.content == IO.binread(upload_path(:jpg))).to be_true
      end

      it "sets asset type based on mime type" do
        expect(@asset.class).to eq(Document)

        visit_edit_form_url(@pid)
        submit_ingest_form_with_upload(:jpg)
        @asset = GenericAsset.find(@pid, cast: true)
        expect(@asset.class).to eq(Image)

        visit_edit_form_url(@pid)
        submit_ingest_form_with_upload(:xml)
        @asset = GenericAsset.find(@pid, cast: true)
        expect(@asset.class).to eq(GenericAsset)
      end
    end

    context "from a template" do
      let(:template) { FactoryGirl.create(:template) }

      before(:each) do
        template
        visit "/ingest"
        click_link(template.title)
      end

      it "should display the template's data" do
        expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[0])
        expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[1])
        expect(page).to include_ingest_fields_for("date", "created", template.templateMetadata.created[0])
      end

      it "should create a new asset" do
        expect {
          click_the_ingest_button
          expect(page).to have_content("Ingested new object")
        }.to change {GenericAsset.count}.by(1)
      end

      it "shouldn't modify the template" do
        fill_in_ingest_data("description", "description", "This is not a useful description")
        fill_in_ingest_data("title", "title", "Overwriting title!")
        click_the_ingest_button

        new_template = Template.first
        expect(new_template.templateMetadata.description).to be_blank
        expect(new_template.templateMetadata.title).to eq(template.templateMetadata.title)
        expect(new_template.templateMetadata.created).to eq(template.templateMetadata.created)
      end
    end

    context "with controlled vocabulary data", :js => true do
      before(:each) do
        visit_ingest_url

        # Choose two subjects to ensure both static and dynamic fields work
        choose_controlled_vocabulary_item("subject", "subject", "food", label1, subject1)
        click_link 'Add subject'
        choose_controlled_vocabulary_item("subject", "subject", "food", label2, subject2, 1)
      end

      it "should store the internal URI, not the label" do
        click_the_ingest_button
        asset = GenericAsset.find(@pid)
        expect(asset.subject.collect {|s| s.rdf_subject}).to eq([subject1, subject2])
      end

      it "should display the label on a subsequent edit" do
        click_the_ingest_button
        visit_edit_form_url(@pid)
        expect(page).to include_ingest_fields_for("subject", "subject", label1)
        expect(page).to include_ingest_fields_for("subject", "subject", label2)
      end

      it "should display the label to the public" do
        click_the_ingest_button
        mark_as_reviewed
        visit(catalog_path(@pid))
        pending "Show view needs to show labels before we can test this!"
        expect(page).to have_content(label1)
        expect(page).to have_content(label2)
      end

      it "should lock down selected controlled vocabulary fields" do
        # Add a subject and get its div
        click_link "Add subject"
        subject_div = ingest_group_nodes("subject").last

        # We should be able to find the empty dropdown option and type in the value field
        selector = "option[value='']"
        expect(subject_div).to have_selector(selector)

        value_field = subject_div.find("input.value-field")
        value_field.native.send_key("blargh")
        expect(value_field.value).to eq("blargh")

        # After choosing an item, however...
        choose_controlled_vocabulary_item("subject", "subject", "food", label1, subject1, 2)

        # ...the empty selector is gone and we can no longer alter the value
        expect(subject_div).not_to have_selector(selector)
        value_field = subject_div.find("input.value-field")
        value_field.native.send_key("blargh")
        expect(value_field.value).to eq(label1)
      end

      it "should fail when a non-URI is freely typed in" do
        click_link "Add subject"
        fill_in_ingest_data("subject", "subject", "Invalid subject", 2)
        click_the_ingest_button
        expect(page).to have_content("Term not in controlled vocabularies: Invalid subject")
      end

      it "should cache the label returned by QA" do
        # Make sure all known labels we could have set are cleared
        sub = OregonDigital::ControlledVocabularies::Subject.from_uri(subject1)
        sub.set_value(RDF::SKOS.prefLabel, [])
        sub.set_value(RDF::SKOS.hiddenLabel, [])
        expect(sub.rdf_label).to eq([subject1])
        sub.persist!

        sub = OregonDigital::ControlledVocabularies::Subject.from_uri(subject1)
        expect(sub.rdf_label).to eq([subject1])
        visit_ingest_url
        choose_controlled_vocabulary_item("subject", "subject", "food", label1, subject1)
        click_the_ingest_button

        visit_edit_form_url(@pid)
        expect(page).to include_ingest_fields_for("subject", "subject", label1)
      end
    end
  end

  context "when updating an existing object" do
    let(:asset) { FactoryGirl.create(:generic_asset, title: "Testing stuffs") }
    let(:pid) { asset.pid }

    before(:each) do
      visit_edit_form_url(pid)
    end

    it "should be pre-filled with data" do
      expect(page).to include_ingest_fields_for("title", "title", "Testing stuffs")
    end

    context "after modifying and submitting the form" do
      before(:each) do
        fill_in_ingest_data("title", "title", "Updated title")
        fill_in_ingest_data("date", "created", "2001-01-01")
        fill_in_ingest_data("description", "description", "This is not a useful description")
        click_the_ingest_button
      end

      it "should succeed" do
        expect(page).to have_content("Updated object")
      end

      it "should look correct when edited again" do
        mark_as_reviewed
        visit_edit_form_url(pid)

        expect(page).to include_ingest_fields_for("title", "title", "Updated title")
        expect(page).not_to include_ingest_fields_for("title", "title", "Testing stuffs")
        expect(page).to include_ingest_fields_for("date", "created", "2001-01-01")
        expect(page).to include_ingest_fields_for("description", "description", "This is not a useful description")
      end
    end
  end
end
