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
        return test if valid_const?(test)
      end
      # Return the class if it constantizes and has a qa_interface
      if valid_const?(replacement) && replacement.constantize.respond_to?(:qa_interface)
        return replacement
      end

      # None worked, default to Qa::Authorities:: prefix
      return super
    end

    # Returns true or false depending on whether `camel_cased_word` is a valid constant.
    #
    # Hacky, but constantize seems the right way to deal with autoloading and such.
    def valid_const?(camel_cased_word)
      begin
        camel_cased_word.constantize
        return true
      rescue NameError
        return false
      end
    end
  end
end
