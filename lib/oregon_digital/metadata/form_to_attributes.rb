class OregonDigital::Metadata::FormToAttributes < Metadata::Ingest::Translators::FormToAttributes
  # Calls superclass to set data, then stores labels for associations that had
  # internal data
  def store_associations_on_object(object, attribute, associations)
    super(object, attribute, associations)

    for assoc in associations
      if assoc.internal
        cache_label(object, attribute, assoc)
      end
    end
  end

  def cache_label(object, attribute, association)
    label = association.value
    uri = association.internal

    klass = object.class

    return unless klass.respond_to?(:properties)

    property = klass.properties[attribute]
    klass = property[:class_name]

    return unless klass.respond_to?(:from_uri)

    vocab_object = klass.from_uri(uri)
    vocab_object.set_value(RDF::SKOS.hiddenLabel, label)
    vocab_object.persist!
  end
end
