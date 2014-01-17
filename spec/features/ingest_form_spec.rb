require 'spec_helper'

# runs all tests using poltergeist, could use :js => true do, to switch between drivers
Capybara.javascript_driver = :poltergeist

$pid_counter = 0
describe "(Ingest Form)", :js => true do
  before(:each) do
    # Ensure ingested objects create predictable and unique pids
    OregonDigital::IdService.stub(:namespace).and_return("spec-feature-ingestform")
    OregonDigital::IdService.stub(:next_id) do
      $pid_counter += 1
      @pid = OregonDigital::IdService.namespaceize($pid_counter)
    end
    visit_ingest_url
  end

  def visit_ingest_url
    visit('/ingest')
    click_link "start from scratch"

    expect(page).to have_selector("input[type=submit]")
  end

  def visit_edit_form_url(pid)
    visit("/ingest/#{pid}/form")
    expect(page).to have_selector("input[type=submit]")
  end

  def fill_out_dummy_data
    fill_in_ingest_data("title", "title", "First Title")
    click_link 'Add title'
    fill_in_ingest_data("title", "title", "Second Title", 1)
    fill_in_ingest_data("date", "created", "2014-01-07")
  end

  def click_the_ingest_button
    button = all(:css, 'input[type=submit]').first
    button.click
    expect(page).to have_content("Ingested new object")
  end

  def mark_as_reviewed
    # Modify the object to be public
    img = GenericAsset.find(@pid)
    img.read_groups = ["public"]
    img.save!

    # set object reviewed
    img.review!
  end

  it "should ingest a new object" do
    visit_ingest_url
    fill_out_dummy_data
    click_the_ingest_button
    mark_as_reviewed

    # Verify on the edit view
    visit_edit_form_url(@pid)
    expect(page).to include_ingest_fields_for("title", "title", "First Title")
    expect(page).to include_ingest_fields_for("title", "title", "Second Title")
    expect(page).to include_ingest_fields_for("date", "created", "2014-01-07")

    # Verify on the show view, too
    visit(catalog_path(@pid))
    expect(page.status_code).to eq(200)
    pending "Need to verify that the show view has the data we ingested"
    expect(page).to have_content('First Title, Second Title')
    expect(page).to have_content('Test Subject')
  end

  it "should fail when data is freely typed into a controlled vocabulary field"

  it "should update an existing object" do
    asset = FactoryGirl.create(:generic_asset, title: "Testing stuffs")
    pid = asset.pid
    visit_edit_form_url(pid)

    # Verify this has the data we expect in the right fields
    div = find(:css, ".nested-fields[data-group=title]")
    element = div.find("input.value-field")
    expect(element.value).to eq("Testing stuffs")

    # Modify some data, add some data
    fill_in_ingest_data("title", "title", "Updated title")
    fill_in_ingest_data("date", "created", "2001-01-01")
    click_link 'Add date'
    fill_in_ingest_data("date", "modified", "2001-01-01", 1)
    fill_in_ingest_data("description", "description", "This is not a useful description")

    click_the_ingest_button
    mark_as_reviewed

    # Hit the edit page and verify data is as expected
    visit_edit_form_url(pid)

    page.driver.resize(1920, 4320)
    page.save_screenshot(Rails.root.join("public", "screen.png"))

    expect(page).to include_ingest_fields_for("title", "title", "Updated title")
    expect(page).not_to include_ingest_fields_for("title", "title", "Testing stuffs")
    expect(page).to include_ingest_fields_for("date", "created", "2001-01-01")
    expect(page).to include_ingest_fields_for("date", "modified", "2001-01-01")
    expect(page).to include_ingest_fields_for("description", "description", "This is not a useful description")

    # Hit the show page, too
    visit(catalog_path(pid))
    expect(page.status_code).to eq(200)

    # object has meta data
    pending "Need to verify that the show view has the data we ingested"
    expect(page).to have_content('First Title, Second Title')
    expect(page).to have_content('Test Subject')
  end

  it "should autocomplete controlled vocabulary fields" do
    visit_ingest_url
    fill_out_dummy_data

    subject_div = all(:css, ".nested-fields[data-group=subject]").first
    title = "Canned foods industry--Accidents"

    # Now you don't see it...
    expect(page).not_to have_content(title)

    within(subject_div) do
      select('subject', :from => "Type")
    end

    # Make typing mimic actual human use
    value_field = subject_div.find("input.value-field")
    value_field.native.send_key("food")

    # ...now you do!  Find it, click it, and ingest
    expect(page).to have_content(title)

    autocomplete_p_tags = all(:css, '.tt-suggestions p')
    autocomplete_p_tags.select {|tag| tag.text == title}.first.click

    # Validate the internal field
    nodes = ingest_group_nodes("subject")
    expect(nodes.count).to eq(1)
    within(nodes.first) do
      internal_field = find("input.internal-field")
      expect(internal_field.value).to eq("http://id.loc.gov/authorities/subjects/sh2007009834")
    end

    click_the_ingest_button
    mark_as_reviewed

    # Hit the edit page and verify data is as expected
    visit_edit_form_url(@pid)
    expect(page).to include_ingest_fields_for("title", "title", "First Title")
    expect(page).to include_ingest_fields_for("title", "title", "Second Title")
    expect(page).to include_ingest_fields_for("date", "created", "2014-01-07")
    expect(page).to include_ingest_fields_for("subject", "subject", "http://id.loc.gov/authorities/subjects/sh2007009834")

    pending "When translation is fixed, get rid of that internal element showing up!"

    # Verify on the show page as well
    visit(catalog_path(@pid))
    expect(page.status_code).to eq(200)
    pending "Need to verify that the show view has the data we ingested"
  end
end
