class OregonDigital::Metadata::FormToAttributes < Metadata::Ingest::Translators::FormToAttributes
  # Calls superclass to set data, then stores labels for associations that had
  # internal data
  def store_associations_on_object(object, attribute, associations)
    for assoc in associations
      unless assoc.internal.blank?
        cache_label(object, attribute, assoc)
        assoc.internal = RDF::URI.new(assoc.internal)
      end
    end

    super(object, attribute, associations)
  end

  def cache_label(object, attribute, association)
    label = association.value
    uri = association.internal

    klass = object.class

    return unless klass.respond_to?(:properties)

    property = klass.properties[attribute]
    klass = property[:class_name]

    return unless klass.respond_to?(:from_uri)

    begin
      vocab_object = klass.from_uri(uri)
    rescue OregonDigital::RDF::Controlled::ControlledVocabularyError
      # This can happen if we're setting invalid data - the form still needs
      # to work without crashing so we can show errors to the user
      Rails.logger.error "Invalid URI: #{uri.inspect} set on #{attribute}"
      return
    end

    vocab_object.set_value(RDF::SKOS.hiddenLabel, label)
    vocab_object.persist!
  end
end
