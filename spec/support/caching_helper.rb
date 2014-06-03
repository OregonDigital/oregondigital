RSpec.configure do |config|
  config.around(:each, :caching => true) do |example|
    caching, ActionController::Base.perform_caching = ActionController::Base.perform_caching, true
    store, ActionController::Base.cache_store = ActionController::Base.cache_store, :memory_store
    Rails.cache = ActionController::Base.cache_store

    example.run

    Rails.cache = store
    ActionController::Base.cache_store = store
    ActionController::Base.perform_caching = caching
  end
end
