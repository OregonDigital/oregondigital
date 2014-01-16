def page_includes_ingest_fields_for?(group, type, value)
  # Can't nest "all" and "find" - "all" returns an Enumerator, not a scoped
  # nodeset of some kind.  So we have to do this nonsense.
  nodes = ingest_group_nodes(group)
  for node in nodes
    within(node) do
      type_field = find("select.type-selector")
      value_field = find("input.value-field")

      return true if type_field.value == type && value_field.value == value
    end
  end

  return false
end

# So... everything is global or something, meaning we don't actually use the
# page variable here, but is there perhaps a nicer way to do this?
RSpec::Matchers.define :include_ingest_fields_for do |group, type, value|
  match do |page|
    page_includes_ingest_fields_for?(group, type, value)
  end
end
