class OregonDigital::Metadata::FormToAttributes < Metadata::Ingest::Translators::FormToAttributes
  # Converts association data, then calls super to store converted data
  def store_associations_on_object(object, attribute, associations)
    associations.each {|assoc| process_association(object, attribute, assoc) }
    super(object, attribute, associations)
  end

  # Checks to see if the given object and attribute need a converted
  # association object, modifying it if so.  If the association needs a
  # conversion, but can't convert due to controlled vocabulary failure,
  # association.errors is given an explanation for use in the UI.
  def process_association(object, attribute, association)
    # This currently happens after translation, which converts deleted records
    # into blank records.  We need to be able to prevent both from causing
    # errors when we try to create RDF objects below.
    return if association.marked_for_destruction? || association.blank?

    rdf_class = get_rdf_class(object, attribute)
    return if !rdf_class

    label = association.value
    uri = association.internal
    uri = association.value if uri.blank?

    begin
      vocab_object = rdf_class.from_uri(uri)
      # Support for objects which HAVE resources (AF::Base objects)
      vocab_object = vocab_object.resource if vocab_object.respond_to?(:resource)
    rescue OregonDigital::RDF::Controlled::ControlledVocabularyError => error
      association.manual_errors.add(:value, error.message)
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
