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

      # None worked, default to Qa::Authorities:: prefix
      return super
    end

    # Returns true or false depending on whether `camel_cased_word` is a valid constant.
    def valid_const?(camel_cased_word)
      names = camel_cased_word.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        return false unless constant.const_defined?(name)
        constant = constant.const_defined?(name) ? constant.const_get(name) : constant.const_missing(name)
      end

      return true
    end
  end
end
