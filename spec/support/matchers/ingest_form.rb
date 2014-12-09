# Checks the page for the given group, type, and value.  Type and value can be
# strings for an exact match or patterns if regex matching is required, e.g.,
# in order to verify that a given group/type doesn't appear at all.
def page_includes_ingest_fields_for?(group, type_pattern, value_pattern)
  # Can't nest "all" and "find" - "all" returns an Enumerator, not a scoped
  # nodeset of some kind.  So we have to do this nonsense.
  nodes = page.send(:ingest_group_nodes,group)
  for node in nodes
    type_field = node.find("select.type-selector")
    value_field = node.find("input.value-field")

    return true if type_pattern === type_field.value && value_pattern === value_field.value
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
