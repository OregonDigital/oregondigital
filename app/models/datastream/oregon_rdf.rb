class Datastream::OregonRDF < OregonDigital::QuadResourceDatastream
  # TODO: use an http URI instead of the PID as a subject
  # rdf_subject { |ds| Utils.rdf_subject(ds.pid) }
  include ActiveFedora::Crosswalks::Crosswalkable
  include OregonDigital::RDF::DeepFetch

  def self.resource_class
    OregonDigital::RDF::ObjectResource
  end
  property :title, :predicate => RDF::DC.title do |index|
    index.as :searchable, :displayable
  end
  property :creator, :predicate => RDF::DC11.creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :contributor, :predicate => RDF::DC11.contributor do |index|
    index.as :searchable, :displayable
  end
  property :abstract, :predicate => RDF::DC.abstract do |index|
    index.as :searchable, :displayable
  end
  property :description, :predicate => RDF::DC.description do |index|
    index.as :searchable, :displayable
  end
  property :subject, :predicate => RDF::DC.subject, :class_name => OregonDigital::ControlledVocabularies::Subject do |index|
      index.as :searchable, :facetable, :displayable
  end
  property :source, :predicate => RDF::DC.source do |index|
    index.as :displayable
  end
  property :type, :predicate => RDF::DC.type, :class_name => OregonDigital::ControlledVocabularies::DCMIType do |index|
    index.as :facetable, :displayable
  end
  property :location, :predicate => RDF::DC.spatial, :class_name => OregonDigital::ControlledVocabularies::Geographic do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :rights, :predicate => RDF::DC.rights, :class_name => OregonDigital::ControlledVocabularies::RightsStatement do |index|
    index.as :displayable
  end
  property :language, :predicate => RDF::DC.language, :class_name => OregonDigital::ControlledVocabularies::Language do |index|
    index.as :displayable, :facetable
  end
  property :identifier, :predicate => RDF::DC.identifier do |index|
    index.as :searchable, :displayable
  end
  property :created, :predicate => RDF::DC.created do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :modified, :predicate => RDF::DC.modified do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :submissionDate, :predicate => RDF::DC.dateSubmitted do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :date, :predicate => RDF::DC.date do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :format, :predicate => RDF::DC.format,  :class_name => OregonDigital::ControlledVocabularies::Format do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :localCollection, :predicate => RDF::DC.isPartOf do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :replacesUrl, :predicate => RDF::DC.replaces

  # MARCRel
  property :photographer, :predicate => OregonDigital::Vocabularies::MARCREL.pht do |index|
    index.as :searchable, :facetable, :displayable
  end

  # Darwin Core
  property :taxonClass, :predicate => OregonDigital::Vocabularies::DWC.class do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :order, :predicate => OregonDigital::Vocabularies::DWC.order do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :family, :predicate => OregonDigital::Vocabularies::DWC.family do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :genus, :predicate => OregonDigital::Vocabularies::DWC.genus do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :phylum, :predicate => OregonDigital::Vocabularies::DWC.phylum do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :higherClassification, :predicate => OregonDigital::Vocabularies::DWC.higherClassification do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :commonNames, :predicate => OregonDigital::Vocabularies::DWC.vernacularName do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :identificationVerificationStatus, :predicate => OregonDigital::Vocabularies::DWC.identificationVerificationStatus do |index|
    index.as :searchable, :facetable, :displayable
  end

  # PREMIS
  property :preservation, :predicate => OregonDigital::Vocabularies::PREMIS.hasOriginalName
  property :hasFixity, :predicate => OregonDigital::Vocabularies::PREMIS.hasFixity

  # Oregon Digital
  property :set, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.set do |index|
    index.as :searchable, :facetable, :displayable
  end

  property :institution, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.contributingInstitution, :class_name => OregonDigital::ControlledVocabularies::Organization do |index|
    index.as :searchable, :facetable, :displayable
  end

  def to_solr(solr_doc = Hash.new)
    fields.each do |field_key, field_info|
      values = resource.get_values(field_key)
      Array.wrap(values).each do |val|
        val = val.to_s if val.kind_of? ::RDF::URI
        val = val.solrize if val.kind_of? ActiveFedora::Rdf::Resource
        Array.wrap(val).each do |solr_val|
          new_key = field_key
          if solr_val.kind_of?(Hash)
            key, solr_val = solr_val.first
            new_key = "#{field_key}_#{key}"
          end
          self.class.create_and_insert_terms(apply_prefix(new_key), solr_val, field_info[:behaviors], solr_doc)
        end
      end
    end
    solr_doc
  end

end
