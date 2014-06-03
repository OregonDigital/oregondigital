# This was a required patch in order to extract the metadata prefix from a resumption token when no other arguments are given.
module OAI::Provider
  class ResumptionToken
    def self.extract_format(token_string)
      return token_string.split('.')[0].split(':')[0]
    end
  end
end
