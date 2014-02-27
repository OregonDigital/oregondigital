require 'spec_helper'

describe "Template authorization rules" do
  let(:attrs) do
    {
      "metadata_ingest_form" => {
        "template_name" => "Foooo!",
        "titles_attributes" => {
          "0" => {"type" => "title", "value" => "test title", "internal" => "", "_destroy" => "false"},
          "1" => {"type" => "title", "value" => "test title number 2", "internal" => "", "_destroy" => "false"},
        }
      }
    }
  end
  let(:template) { FactoryGirl.create(:template) }

  subject { page }

  context "on the home page" do
    before(:each) do
      capybara_login(user)
      visit "/"
    end

    context "for a regular user", role: nil do
      it { should_not show_template_link }
    end

    context "for a submitter", role: :submitter do
      it { should_not show_template_link }
    end

    context "for an archivist", role: :archivist do
      it { should show_template_link }
    end

    context "for an admin", role: :admin do
      it { should show_template_link }
    end
  end

  context "when visiting the template index" do
    before(:each) do
      capybara_login(user)
      visit templates_path
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("create") }
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("create") }
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }
    end
  end

  context "when starting a new form" do
    before(:each) do
      capybara_login(user)
      visit new_template_path
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("create") }
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("create") }
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }
    end
  end

  context "when manually submitting a template" do
    before(:each) do
      capybara_login(user)
      page.driver.browser.process_and_follow_redirects(:post, templates_path, attrs)
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("create") }

      it "shouldn't create an object" do
        expect(Template.count).to eq(0)
      end
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("create") }

      it "shouldn't create an object" do
        expect(Template.count).to eq(0)
      end
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }

      it "should create an object" do
        expect(Template.count).to eq(1)
      end
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }

      it "should create an object" do
        expect(Template.count).to eq(1)
      end
    end
  end

  context "when visiting an edit form" do
    before(:each) do
      capybara_login(user)
      visit edit_template_path(template.pid)
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("update") }
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("update") }
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }
    end
  end

  context "when manually submitting an update" do
    before(:each) do
      capybara_login(user)
      page.driver.browser.process_and_follow_redirects(:patch, template_path(template.pid), attrs)
      @new_template = Template.find(template.pid)
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("update") }

      it "shouldn't modify the object" do
        expect(@new_template.templateMetadata.title).to eq(["Test title", "Another"])
      end
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("update") }

      it "shouldn't modify the object" do
        expect(@new_template.templateMetadata.title).to eq(["Test title", "Another"])
      end
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }

      it "should modify the object" do
        expect(@new_template.templateMetadata.title).to eq(["test title", "test title number 2"])
      end
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }

      it "should modify the object" do
        expect(@new_template.templateMetadata.title).to eq(["test title", "test title number 2"])
      end
    end
  end

  context "when manually submitting a delete" do
    before(:each) do
      capybara_login(user)
      page.driver.browser.process_and_follow_redirects(:delete, template_path(template.pid))
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("delete") }

      it "shouldn't delete the object" do
        expect(Template.count).to eq(1)
      end
    end

    context "for a submitter", role: :submitter do
      it { should have_permissions_error("delete") }

      it "shouldn't delete the object" do
        expect(Template.count).to eq(1)
      end
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }

      it "should delete the object" do
        expect(Template.count).to eq(0)
      end
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }

      it "should delete the object" do
        expect(Template.count).to eq(0)
      end
    end
  end
end
