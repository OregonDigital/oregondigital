class OregonDigital::Metadata::AttributeTranslator < Metadata::Ingest::Translators::SingleAttributeTranslator
  # Overrides the built-in association builder to translate URI to user-friendly label in cases where
  # the attribute being assigned has an RDF resource backing it
  def build_association(value)
    assoc = super(value)

    if assoc.value.is_a?(ActiveFedora::Rdf::Resource)
      assoc.internal = assoc.value.rdf_subject.to_s
      assoc.value = assoc.value.rdf_label.first
    end

    return assoc
  end
end
