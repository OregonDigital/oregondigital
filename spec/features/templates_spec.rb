require 'spec_helper'

# runs all tests using poltergeist, could use :js => true do, to switch between drivers
Capybara.javascript_driver = :poltergeist

# A lot of the magic in templates is just ingest form stuff, and won't be
# re-tested.  If we ever make templates rely on their own logic instead of
# piggybacking off ingest form stuff, this will have to change.
describe "(Administration of templates)", :js => true do
  let(:admin) {FactoryGirl.create(:admin)}

  before(:each) do
    capybara_login(admin)
  end

  context "The template index" do
    let(:template_1) { FactoryGirl.create(:template) }
    let(:template_2) { FactoryGirl.create(:template, :with_description) }

    before(:each) do
      template_1
      template_2
      visit "/"
      within(".navbar") do
      click_link "Templates"
      end
    end

    it "should render a list of templates" do
      expect(page.all("table tr")[1].all("td").first.text).to eq("Edit #{template_1.title}")
      expect(page.all("table tr")[2].all("td").first.text).to eq("Edit #{template_2.title}")

      # 3 because of the table header row
      expect(page.all("table tr").length).to eq(3)
    end

    context "(when deleting a template)" do
      before(:each) do
        click_link("Delete #{template_2.title}")
      end

      it "should remove the template from the list" do
        expect(page.all("table tr")[1].all("td").first.text).to eq("Edit #{template_1.title}")
        expect(page.all("table tr").length).to eq(2)
      end

      it "should give me a notice that the template was deleted" do
        expect(page).to have_content("Deleted template '#{template_2.title}'")
      end
    end

    context "(when cloning a template)" do
      before(:each) do
        click_link("Clone #{template_2.title}")
      end

      it "should present a pre-filled form" do
        expect(page).to include_ingest_fields_for("title", "title", template_2.templateMetadata.title[0])
        expect(page).to include_ingest_fields_for("title", "title", template_2.templateMetadata.title[1])
        expect(page).to include_ingest_fields_for("description", "description", template_2.templateMetadata.description[0])
      end

      it "should create a new template" do
        # This name isn't trying to suggest templates will destroy the world;
        # it was actually chosen to ensure the new template is pushed to the
        # top of the list.
        fill_in "Template name", with: "Apocalypse template"
        find(:css, 'input[type=submit]').click

        expect(page.all("table tr")[1].all("td").first.text).to eq("Edit Apocalypse template")
        expect(page.all("table tr")[2].all("td").first.text).to eq("Edit #{template_1.title}")
        expect(page.all("table tr")[3].all("td").first.text).to eq("Edit #{template_2.title}")
        expect(page.all("table tr").length).to eq(4)
      end
    end
  end

  context "The 'new template' form" do
    let(:collection) do
      c = FactoryGirl.create(:generic_collection, :title => "Alabama")
      c.review!
      c
    end

    before(:each) do
      collection
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

      context "with a set" do
        before do
          choose_collection("set", collection.title)
        end
        it "should succeed" do
          find(:css, 'input[type=submit]').click
          expect(page).to have_content("Created Template")
        end
        context "and then it's edited" do
          before do
            find(:css, 'input[type=submit]').click
            expect(page).to have_content("Created Template")
            click_link "Edit My First Template (tm)"
          end
          it "should show that set's value" do
            expect(page).to include_ingest_fields_for("collection", "set",
                "http://oregondigital.org/resource/#{collection.pid}")
          end
        end
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

      context "on partially filled forms" do
        let(:title_nodes) { ingest_group_nodes("title") }
        let(:first_title_node) { title_nodes[0] }

        context "when a type is filled in but its value isn't" do
          before(:each) do
            within(first_title_node) do
              fill_in("Value", :with => "")
            end
          end

          it "shouldn't give errors" do
            find(:css, 'input[type=submit]').click
            expect(page).to have_content("Created Template")
          end

          it "should preserve the empty value when re-editing the template" do
            find(:css, 'input[type=submit]').click
            expect(page).to have_content("Created Template")

            click_link "Edit My First Template (tm)"
            expect(page).to include_ingest_fields_for("title", "title", "")
          end
        end

        context "when a value is filled in but its type isn't" do
          before(:each) do
            within(first_title_node) do
              select("", :from => "Type")
            end
          end

          it "should still give errors when a type is invalid but value is filled in" do
            find(:css, 'input[type=submit]').click
            expect(page).to have_content("Title type cannot be blank")
          end
        end
      end
    end
  end

  context "The 'edit template' form" do
    let(:template) { FactoryGirl.create(:template) }

    before(:each) do
      template
      visit "/templates"
      click_link "Edit Test template"
    end

    it "should render the form with data" do
      expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[0])
      expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[1])
      expect(page).to include_ingest_fields_for("date", "created", template.templateMetadata.created[0])
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
        expect(page.find("table a[href$=edit]")).to have_content(template.title)
      end

      it "should have the new data if we revisit the form" do
        find(:css, 'input[type=submit]').click
        click_link "Edit Test template"

        expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[0])
        expect(page).to include_ingest_fields_for("title", "title", template.templateMetadata.title[1])
        expect(page).to include_ingest_fields_for("date", "created", template.templateMetadata.created[0])
        expect(page).to include_ingest_fields_for("description", "description", "This is not a useful description")
        expect(page).to have_selector("input[type=submit]")
      end
    end
  end
end
