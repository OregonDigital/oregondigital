module OregonDigital::Qa
  module Caching
    def search(*args)
      Rails.cache.fetch("od_qa_cache/#{self.class}/#{args.first}", :expires_in => cache_time) do
        super
      end
    end

    def cache_time
      30.days
    end
  end
end
