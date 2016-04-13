require 'spec_helper'

describe 'bulk tasks', :js => true do
  let(:admin) {FactoryGirl.create(:admin)}
  let(:asset) do
    a = GenericAsset.new
    graph = RDF::Graph.load(Rails.root.join("spec", "fixtures", "fixture_triples.nt"))
    a.resource << graph
    a.save
    a.stub(:bag_path).and_return(Rails.root.join("tmp", "bags", "bulkloads", "1").to_s)
    a
  end
  let(:bag) do
    MIME::Types.stub(:[]).and_call_original
    extensions = ["nt"]
    results = double()
    results.stub(:extensions).and_return(extensions)
    MIME::Types.stub(:[]).with("application/n-triples").and_return([results])
    asset.write_bag
    asset.bag
  end
  let(:bulk_task) do
    bag
    asset.destroy
    BulkTask.create(:directory => "bulkloads")
  end
  before do
    Dir.stub(:glob).and_call_original
    APP_CONFIG.stub(:batch_dir).and_return(Rails.root.join("tmp", "bags"))
    visit root_path
    capybara_login(admin)
    bulk_task
    Dir.stub(:glob).with(Rails.root.join("tmp", "bags")).and_return(Rails.root.join("tmp", "bags", "bulkloads"))
    visit bulk_tasks_path
  end
  after do
    FileUtils.rm_rf(Rails.root.join("tmp", "bags", "bulkloads"))
  end
  it "should show one bulk task" do
    within("table") do
      expect(page).to have_content("bulkloads")
      expect(page).to have_content("New")
      expect(page).to have_content("Ingest")
      expect(page).to have_content("Refresh")
      expect(page).to have_content("Reset")
    end
  end
  context "and the refresh button is clicked" do
    context "and the first child is ingested" do
      before do
        child = bulk_task.bulk_task_children.first
        child.status = "ingested"
        child.save
      end
      context "and there's a new directory" do
        before do
          FileUtils.cp_r(bag.bag_dir, Pathname.new(bag.bag_dir).dirname.join("2").to_s)
          within("table") do
            click_link "Refresh", :match => :first
          end
        end
        it "should create a new child" do
          within("table") do
            expect(page).to have_content("2")
          end
        end
        it "should have the ingest button again" do
          expect(page).to have_link "Ingest"
        end
      end
    end
  end
  context "and it's ingested", :resque => true do
    before do
      GenericAsset.any_instance.stub(:queue_fetch)
    end
    context "and an error is raised" do
      before do
        GenericAsset.any_instance.stub(:save).and_raise("AAAH IT'S BUSTED")
        within("table") do
          click_link "Ingest", :match => :first
        end
      end
      it "should not ingest and should show an error" do
        within("table") do
          expect(page).to have_content("Errored")
          expect(page).to have_link "Retry Ingest"
        end
        expect(ActiveFedora::Base.all.length).to eq 0
      end
      context "and the ingest is retried" do
        before do
          GenericAsset.any_instance.unstub(:save)
          click_link "Retry Ingest"
        end
        it "should ingest" do
          within("table") do
            expect(page).to have_content("Ingested")
          end
        end
      end
      context "and the directory is clicked" do
        before do
          click_link "bulkloads"
        end
        it "should show an errored status" do
          within("table") do
            expect(page).to have_content "errored"
          end
          expect(page).to have_link "Retry Ingest"
        end
        context "and the child item is clicked" do
          before do
            within("table") do
              find("td a").click
            end
          end
          it "should show an error message" do
            expect(page).to have_content("AAAH IT'S BUSTED")
            expect(page).to have_content("Stack Trace")
          end
        end
      end
    end
    context "and everything's okay" do
      before do
        within("table") do
          click_link "Ingest", :match => :first
        end
      end
      context "and resque hasn't run yet", :resque => false do
        it "should show as ingesting" do
          within("table") do
            expect(page).to have_content("Ingesting")
          end
          expect(Resque.size("ingest")).to eq 1
        end
        it "should have a stop button" do
          expect(page).to have_content("Stop Ingest")
        end
        context "and one child is already ingested" do
          before do
            b = BulkTaskChild.create(:bulk_task => bulk_task, :target => "blabla", :status => "ingested", :ingested_pid => 100)
            click_link "Stop Ingest"
          end
          it "should delete resque tasks" do
            expect(Resque.size("ingest")).to eq 0
          end
          it "should have an ingest button" do
            within("table") do
              expect(page).to have_link("Ingest")
            end
          end
        end
        context "and the stop button is clicked" do
          before do
            click_link "Stop Ingest"
          end
          it "should mark the status as new" do
            within "table" do
              expect(page).to have_content("New")
            end
            expect(page).to have_link("Ingest")
          end
          it "should delete resque tasks" do
            expect(Resque.size("ingest")).to eq 0
          end
        end
      end
      it "should ingest the item" do
        within("table") do
          expect(page).to have_content("Ingested")
          expect(page).to have_link "Review All"
          expect(page).to have_link "Delete All"
        end
        expect(ActiveFedora::Base.all.length).to eq 1
      end
      context "and the delete all link is clicked" do
        context "and everything is okay" do
          before do
            click_link "Delete All"
          end
          it "should delete all the items" do
            within("table") do
              expect(page).to have_content("Deleted")
            end
            expect(GenericAsset.all.length).to eq 0
          end
        end
        context "and something goes wrong" do
          before do
            GenericAsset.any_instance.stub(:destroy).and_raise("SO MANY ERRORS")
            click_link "Delete All"
          end
          it "should set status to errored" do
            within("table") do
              expect(page).to have_content("Errored")
            end
          end
          it "should have a retry delete button" do
            within("table") do
              expect(page).to have_content("Retry Delete")
              expect(page).not_to have_content("Retry Ingest")
            end
          end
          context "and everything is fixed" do
            before do
              GenericAsset.any_instance.unstub(:destroy)
              click_link "Retry Delete"
            end
            it "should delete" do
              expect(page).to have_content("Deleted")
            end
          end
        end
      end
      context "and the review all link is clicked" do
        context "and everything is okay" do
          before do
            click_link "Review All"
          end
          it "should review all items" do
            within("table") do
              expect(page).to have_content("Reviewed")
              expect(page).not_to have_link "Delete All"
            end
            expect(GenericAsset.first).to be_reviewed
          end
        end
        context "and something goes wrong" do
          before do
            GenericAsset.any_instance.stub(:review!).and_raise("SO MANY ERRORS")
            click_link "Review All"
            expect(page).to have_content("Queued batch review")
          end
          it "should set status to errored" do
            within("table") do
              expect(page).to have_content("Errored")
            end
          end
          context "and it's fixed" do
            before do
              GenericAsset.any_instance.unstub(:review!)
              click_link "Retry Review"
            end
            it "should ingest right" do
              expect(page).to have_content("Reviewed")
              expect(GenericAsset.all.length).to eq 1
              expect(GenericAsset.first).to be_reviewed
            end
          end
          context "on the child page" do
            before do
              visit bulk_task_child_path(BulkTaskChild.last.id)
              sleep(1)
            end
            it "should have the error" do
              expect(page).to have_content("Failed During reviewing")
              expect(page).to have_content("SO MANY ERRORS")
            end
          end
        end
      end
    end
  end
end
