module OregonDigital::Qa
  module CustomAuthorityClass
    # Specifies the list of patterns for looking up a class.  Patterns should have a single "%s"
    # in them as a placeholder for the parameter
    def self.qa_class_patterns=(list)
      @qa_class_patterns = list
    end

    def self.qa_class_patterns
      return @qa_class_patterns
    end

    private

    def authority_class
      # We do not capitalize here since our namespaces are deeper than one level
      replacement = params[:vocab]
      for pattern in OregonDigital::Qa::CustomAuthorityClass.qa_class_patterns
        test = pattern % replacement
        Rails.logger.info "Testing out #{test}"
        return test if valid_class?(test)
      end

      # None worked, default to Qa::Authorities:: prefix
      Rails.logger.info "Falling back to default"
      return super
    end

    # Returns true or false depending on whether `class_string` is a valid constant.
    #
    # NOTE: Yes, this is hacky, but easier than recreating the constantize method.
    def valid_class?(class_string)
      begin
        return true if class_string.constantize
      rescue NameError
        return false
      end
    end
  end
end
