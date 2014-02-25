require 'spec_helper'

describe "Ingest form authorization rules" do
  let(:attrs) do
    {
      "metadata_ingest_form" => {
        "titles_attributes" => {
          "0" => {"type" => "title", "value" => "test title", "internal" => "", "_destroy" => "false"},
          "1" => {"type" => "title", "value" => "test title number 2", "internal" => "", "_destroy" => "false"}
        }
      }
    }
  end

  subject { page }

  context "on the home page" do
    before(:each) do
      capybara_login(user)
      visit "/"
    end

    context "for a regular user", role: nil do
      it { should_not show_ingest_link }
    end

    context "for a submitter", role: :submitter do
      it { should show_ingest_link }
    end

    context "for an archivist", role: :archivist do
      it { should show_ingest_link }
    end

    context "for an admin", role: :admin do
      it { should show_ingest_link }
    end
  end

  context "when visiting the ingest index" do
    before(:each) do
      capybara_login(user)
      visit ingest_index_path
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("ingest") }
    end

    context "for a submitter", role: :submitter do
      it { should_not have_permissions_error }
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
      visit new_ingest_path
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("ingest") }
    end

    context "for a submitter", role: :submitter do
      it { should_not have_permissions_error }
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }
    end
  end

  context "when manually submitting an object" do
    before(:each) do
      capybara_login(user)
      page.driver.browser.process_and_follow_redirects(:post, "/ingest", attrs)
    end

    context "for a regular user", role: nil do
      it { should have_permissions_error("ingest") }

      it "shouldn't create an object" do
        expect(GenericAsset.count).to eq(0)
      end
    end

    context "for a submitter", role: :submitter do
      it { should_not have_permissions_error }

      it "should create an object" do
        expect(GenericAsset.count).to eq(1)
      end
    end

    context "for an archivist", role: :archivist do
      it { should_not have_permissions_error }

      it "should create an object" do
        expect(GenericAsset.count).to eq(1)
      end
    end

    context "for an admin", role: :admin do
      it { should_not have_permissions_error }

      it "should create an object" do
        expect(GenericAsset.count).to eq(1)
      end
    end
  end
end
