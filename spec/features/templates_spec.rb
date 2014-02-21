require 'spec_helper'

# runs all tests using poltergeist, could use :js => true do, to switch between drivers
Capybara.javascript_driver = :poltergeist

# A lot of the magic in templates is just ingest form stuff, and won't be
# re-tested.  If we ever make templates rely on their own logic instead of
# piggybacking off ingest form stuff, this will have to change.
describe "(Administration of templates)", :js => true do
  context "The template index" do
    before(:each) do
      template = Template.new
      template.name = "Test template"
      template.save!
      template = Template.new
      template.title = ["Test title", "Another"]
      template.description = ["Foo"]
      template.name = "Test template 2"
      template.save!

      visit "/templates"
    end

    it "should render a list of templates" do
      expect(page.all("table tr")[1].all("td").first.text).to eq("Edit Test template")
      expect(page.all("table tr")[2].all("td").first.text).to eq("Edit Test template 2")

      # 3 because of the table header row
      expect(page.all("table tr").length).to eq(3)
    end

    context "(when deleting a template)" do
      before(:each) do
        click_link("Delete Test template 2")
      end

      it "should remove the template from the list" do
        expect(page.all("table tr")[1].all("td").first.text).to eq("Edit Test template")
        expect(page.all("table tr").length).to eq(2)
      end

      it "should give me a notice that the template was deleted" do
        expect(page).to have_content("Deleted template 'Test template 2'")
      end
    end

    context "(when cloning a template)" do
      before(:each) do
        click_link("Clone Test template 2")
      end

      it "should present a pre-filled form" do
        expect(page).to include_ingest_fields_for("title", "title", "Test title")
        expect(page).to include_ingest_fields_for("title", "title", "Another")
        expect(page).to include_ingest_fields_for("description", "description", "Foo")
      end

      it "should create a new template" do
        fill_in "Template name", with: "Test template 3"
        find(:css, 'input[type=submit]').click

        expect(page.all("table tr")[1].all("td").first.text).to eq("Edit Test template")
        expect(page.all("table tr")[2].all("td").first.text).to eq("Edit Test template 2")
        expect(page.all("table tr")[3].all("td").first.text).to eq("Edit Test template 3")
        expect(page.all("table tr").length).to eq(4)
      end
    end
  end

  context "The 'new template' form" do
    before(:each) do
      visit "/templates"
      click_link "Create new template"
    end

    it "should render empty fields" do
      nodes = page.all(:css, ".value-field")
      for node in nodes
        expect(node.value).to be_blank
      end
      expect(page).to have_selector("input[type=submit]")
    end

    context "when submitted with data" do
      before(:each) do
        fill_in "Template name", with: "My First Template (tm)"
        fill_in_ingest_data("title", "title", "First Title")
        click_link 'Add title'
        fill_in_ingest_data("title", "title", "Second Title", 1)
        fill_in_ingest_data("date", "created", "2014-01-07")
      end

      it "should give me a notification that the template was created" do
        find(:css, 'input[type=submit]').click
        expect(page).to have_content("Created Template")
      end

      it "should redirect to the template listings with the new template shown" do
        find(:css, 'input[type=submit]').click
        expect(page.find("table > caption")).to have_content("Available Templates")
        expect(page.find("table a[href$=edit]")).to have_content("My First Template (tm)")
      end
    end
  end

  context "The 'edit template' form" do
    before(:each) do
      template = Template.new
      template.name = "Test template"
      template.descMetadata.title = ["Test title", "Another"]
      template.descMetadata.created = ["2011-01-01"]
      template.save!

      visit "/templates"
      click_link "Edit Test template"
    end

    it "should render the form with data" do
      expect(page).to include_ingest_fields_for("title", "title", "Test title")
      expect(page).to include_ingest_fields_for("title", "title", "Another")
      expect(page).to include_ingest_fields_for("date", "created", "2011-01-01")
      expect(page).to have_selector("input[type=submit]")
    end

    context "when submitted with data" do
      before(:each) do
        fill_in_ingest_data("description", "description", "This is not a useful description")
      end

      it "should give me a notification that the template was updated" do
        find(:css, 'input[type=submit]').click
        expect(page).to have_content("Updated Template")
      end

      it "should redirect to the template listings with the template shown" do
        find(:css, 'input[type=submit]').click
        expect(page.find("table > caption")).to have_content("Available Templates")
        expect(page.find("table a[href$=edit]")).to have_content("Test template")
      end

      it "should have the new data if we revisit the form" do
        find(:css, 'input[type=submit]').click
        click_link "Edit Test template"

        expect(page).to include_ingest_fields_for("title", "title", "Test title")
        expect(page).to include_ingest_fields_for("title", "title", "Another")
        expect(page).to include_ingest_fields_for("date", "created", "2011-01-01")
        expect(page).to include_ingest_fields_for("description", "description", "This is not a useful description")
        expect(page).to have_selector("input[type=submit]")
      end
    end
  end
end
