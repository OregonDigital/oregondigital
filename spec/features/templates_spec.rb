require 'spec_helper'

# runs all tests using poltergeist, could use :js => true do, to switch between drivers
Capybara.javascript_driver = :poltergeist

# A lot of the magic in templates is just ingest form stuff, and won't be
# re-tested.  If we ever make templates rely on their own logic instead of
# piggybacking off ingest form stuff, this will have to change.
describe "(Administration of templates)", :js => true do
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
end
