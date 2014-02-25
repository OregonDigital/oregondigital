require 'spec_helper'

describe "Ingest form authorization rules" do
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
end
