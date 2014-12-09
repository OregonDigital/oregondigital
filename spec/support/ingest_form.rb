def visit_ingest_url
  visit('/')
  within(".navbar") do
    click_link "Ingest"
  end
  click_link "Start from scratch"
end

def fill_out_dummy_data
  fill_in_ingest_data("title", "title", "Asset Title")
  fill_in_ingest_data("date", "created", "2014-01-07")
  fill_in_ingest_data("description", "description", "This is an asset")
end

def click_the_ingest_button
  find('input.btn-primary').click
end

def ingest_group_nodes(group)
  return all(".nested-fields[data-group=#{group}]")
end

def fill_in_ingest_data(group, type, value, position = 0, clone = false)
  type = OregonDigital::Metadata::FieldTypeLabel.for(type)
  nodes = ingest_group_nodes(group)
  node = nodes[position]
  within(node) do
    select(type, :from => "Type")
    fill_in("Value", :with => value)

    if clone
      # This is unfortunate, but in some cases we have checkboxes on the form,
      # but under the header, so JS-enabled capybara tests click the spot where
      # the checkbox exists, but get the header element.
      find("input.clone-field").trigger('click')
    end
  end
end

def choose_controlled_vocabulary_item(group, type, search, pick, internal, position = 0)
  # Expectations are here to ensure tests for CV stuff stay solid
  expect(page).not_to have_content(pick)

  type = OregonDigital::Metadata::FieldTypeLabel.for(type)

  group_div = ingest_group_nodes(group)[position]
  group_div.select(type, :from => "Type")

  # Make typing mimic actual human use
  value_field = group_div.find("input.value-field")
  value_field.native.send_key(search)

  # These serve as tests as well as pauses - capybara will wait a bit on
  # has_content?, so the typeahead content can show up
  expect(page).to have_content(pick)
  expect(page).to have_content(internal)

  autocomplete_tags = all('.tt-suggestion .suggestion-label')
  autocomplete_tags.select {|tag| tag.text == pick}.first.click

  # Validate the internal field
  internal_field = group_div.find("input.internal-field")
  expect(internal_field.value).to eq(internal)
end

def upload_path(type)
  map = {
    jpg: "fixture_image.jpg",
    pdf: "fixture_pdf.pdf",
    xml: "fixture_xml.xml",
    yml: "fixture_yml.yml",
  }
  file_path = Rails.root.join("spec", "fixtures", map[type]).to_s
end

def submit_ingest_form_with_upload(filetype = :pdf)
  attach_file("Upload", upload_path(filetype))
  click_the_ingest_button
end
