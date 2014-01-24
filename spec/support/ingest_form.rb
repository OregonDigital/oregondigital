def ingest_group_nodes(group)
  return all(:css, ".nested-fields[data-group=#{group}]")
end

def fill_in_ingest_data(group, type, value, position = 0)
  within(ingest_group_nodes(group)[position]) do
    select(type, :from => "Type")
    fill_in("Value", :with => value)
  end
end

def choose_controlled_vocabulary_item(group, type, search, pick, internal, position = 0)
  # Expectations are here to ensure tests for CV stuff stay solid
  expect(page).not_to have_content(pick)

  group_div = ingest_group_nodes(group)[position]
  group_div.select(type, :from => "Type")

  # Make typing mimic actual human use
  value_field = group_div.find("input.value-field")
  value_field.native.send_key(search)

  # These serve as tests as well as pauses - capybara will wait a bit on
  # has_content?, so the typeahead content can show up
  expect(page).to have_content(pick)
  expect(page).to have_content(internal)

  autocomplete_tags = all(:css, '.tt-suggestion .suggestion-label')
  autocomplete_tags.select {|tag| tag.text == pick}.first.click

  # Validate the internal field
  internal_field = group_div.find("input.internal-field")
  expect(internal_field.value).to eq(internal)
end
