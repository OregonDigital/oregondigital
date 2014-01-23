class OregonDigital::Metadata::AttributeTranslator < Metadata::Ingest::Translators::SingleAttributeTranslator
  # Overrides the built-in association builder to translate URI to user-friendly label in cases where
  # the attribute being assigned has an RDF resource backing it
  def build_association(value)
    assoc = super(value)
    klass = @object.class

    return assoc unless klass.respond_to?(:properties)

    property = klass.properties[@attribute]
    klass = property[:class_name]

    return assoc unless klass.respond_to?(:from_uri)

    assoc.internal = assoc.value
    assoc.value = klass.from_uri(assoc.internal).rdf_label.first

    return assoc
  end
end
