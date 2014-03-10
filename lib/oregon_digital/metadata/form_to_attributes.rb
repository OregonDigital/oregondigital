class OregonDigital::Metadata::FormToAttributes < Metadata::Ingest::Translators::FormToAttributes
  # Converts association data, then calls super to store converted data
  def store_associations_on_object(object, attribute, associations)
    associations.each {|assoc| process_association(object, attribute, assoc) }
    super(object, attribute, associations)
  end

  # Checks to see if the given object and attribute need a converted
  # association object, modifying it if so.  If the association needs a
  # conversion, but can't convert due to controlled vocabulary failure,
  # the conversion is aborted.
  def process_association(object, attribute, association)
    return if association.marked_for_destruction?

    rdf_class = get_rdf_class(object, attribute)
    return if !rdf_class

    label = association.value
    uri = association.internal
    uri = association.value if uri.blank?

    begin
      vocab_object = rdf_class.from_uri(uri)
    rescue OregonDigital::RDF::Controlled::ControlledVocabularyError
      Rails.logger.error "Invalid URI: #{uri.inspect} set on #{attribute}"
      return
    end

    association.internal = RDF::URI.new(uri)

    # Cache the label so show/edit work even if we have never seen this term
    # before (and don't want to refresh our internal terms all the time)
    vocab_object.set_value(RDF::SKOS.hiddenLabel, label)
    vocab_object.persist!
  end

  # Returns the RDF Resource class for the given object and attribute if one
  # exists, or nil if there isn't one
  def get_rdf_class(object, attribute)
    return nil unless object.class.respond_to?(:properties)

    property = object.class.properties[attribute]
    klass = property[:class_name]

    return nil unless klass.respond_to?(:from_uri)

    return klass
  end
end
