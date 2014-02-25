# Matchers to help ensure permissions checks are consistent from one role to
# the next

RSpec::Matchers.define :show_ingest_link do
  match do |page|
    page.has_link?("Ingest")
  end
end
