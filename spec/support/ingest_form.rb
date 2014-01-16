def ingest_group_nodes(group)
  return all(:css, ".nested-fields[data-group=#{group}]")
end

def fill_in_ingest_data(group, type, value, position = 0)
  within(ingest_group_nodes(group)[position]) do
    select(type, :from => "Type")
    fill_in("Value", :with => value)
  end
end
