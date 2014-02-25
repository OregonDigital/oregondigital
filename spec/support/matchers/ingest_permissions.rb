# Matchers to help ensure permissions checks are consistent from one role to
# the next

RSpec::Matchers.define :show_ingest_link do
  match do |page|
    page.has_link?("Ingest")
  end
end

RSpec::Matchers.define :have_permissions_error do |suffix = ""|
  match do |page|
    begin
      page.within("#main-flashes") do
        page.has_content?(/do not have permission to #{suffix}/i)
      end
    rescue Capybara::ElementNotFound
      false
    end
  end
end
