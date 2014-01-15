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

  def fill_out_dummy_data
    nodes = all(:css, ".nested-fields[data-group=title]")
    within(nodes.first) do
      select("title", :from => "Type")
      fill_in("Value", :with => "First Title")
    end

    click_link 'Add title'
    nodes = all(:css, ".nested-fields[data-group=title]")
    within(nodes[1]) do
      select("title", :from => "Type")
      fill_in("Value", :with => "Second Title")
    end

    # Fill out the created date
    nodes = all(:css, ".nested-fields[data-group=date]")
    within(nodes.first) do
      select('created', :from => "Type")
      fill_in("Value", :with => '2014-01-07')
    end
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

    visit(catalog_path(@pid))
    expect(page.status_code).to eq(200)

    # object has meta data
    pending "Need to verify that the show view has the data we ingested"
    expect(page).to have_content('First Title, Second Title')
    expect(page).to have_content('Test Subject')
  end

  it "should fail when data is freely typed into a controlled vocabulary field"

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

    click_the_ingest_button
    mark_as_reviewed

    visit(catalog_path(@pid))
    expect(page.status_code).to eq(200)
    pending "Need to verify that the show view has the data we ingested"
  end
end
