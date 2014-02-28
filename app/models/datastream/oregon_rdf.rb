class Datastream::OregonRDF < OregonDigital::QuadResourceDatastream
  include ActiveFedora::Crosswalks::Crosswalkable

  def resource_class
    OregonResource
  end

  map_predicates do |map|

    # Core Properties
    map.title(:in => RDF::DC) do |index|
      index.as :searchable, :displayable
    end
    map.creator(:in => RDF::DC11) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.contributor(:in => RDF::DC11) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.abstract(:in => RDF::DC) do |index|
      index.as :searchable, :displayable
    end
    map.description(:in => RDF::DC) do |index|
      index.as :searchable, :displayable
    end
    map.subject(:in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::Subject) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.source(:in => RDF::DC) do |index|
      index.as :displayable
    end
    map.type(:in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::DCMIType) do |index|
      index.as :facetable, :displayable
    end
    map.location(:to => 'spatial', :in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::Geographic) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.rights(:in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::RightsStatement) do |index|
      index.as :displayable
    end
    map.language(:in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::Language) do |index|
      index.as :displayable, :facetable
    end
    map.identifier(:in => RDF::DC) do |index|
      index.as :searchable, :displayable
    end
    map.created(:in => RDF::DC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.modified(:in => RDF::DC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.submissionDate(:to => 'dateSubmitted', :in => RDF::DC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.date(:in => RDF::DC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.format(:to => 'format', :in => RDF::DC, :class_name => OregonDigital::ControlledVocabularies::Format) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.localCollection(:to => 'isPartOf', :in => RDF::DC) do |index|
      index.as :searchable, :facetable, :displayable
    end

    map.replacesUrl(:to => 'replaces', :in => RDF::DC) # do not index

    # MARCRel
    # These fields should all be searchable as equivalent to dc.contributor
  # map.contributor[?](:to => "*", :in => RDF::MARCRel) do |index|
  #   index.as :searchable, :facetable, :displayable
  # end
    map.photographer(:to => 'pht', :in => OregonDigital::Vocabularies::MARCREL) do |index|
      index.as :searchable, :facetable, :displayable
    end

    # Darwin Core
    map.taxonClass(:to => 'class', :in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.order(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.family(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.genus(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.phylum(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.higherClassification(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.commonNames(:to => 'vernacularName', :in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end
    map.identificationVerificationStatus(:in => OregonDigital::Vocabularies::DWC) do |index|
      index.as :searchable, :facetable, :displayable
    end

    # PREMIS
    map.preservation(:to => 'hasOriginalName', :in => OregonDigital::Vocabularies::PREMIS)
    map.hasFixity(:in => OregonDigital::Vocabularies::PREMIS) # don't index

    # Oregon Digital
    map.set(:in => OregonDigital::Vocabularies::OREGONDIGITAL) do |index|
      index.as :searchable, :facetable, :displayable
    end

    property :institution, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.contributingInstitution, :class_name => OregonDigital::ControlledVocabularies::Organization do |index|
      index.as :searchable, :facetable, :displayable
    end
  end

  def to_solr(doc = {})
    doc = super
    # Magic mystery fun code for making marc act like solr
    # doc["dc_contributor_t"] = doc["dc_photographer"] + ...
    doc
  end

  class OregonResource < ActiveFedora::Rdf::ObjectResource
    configure :base_uri => 'http://oregondigital.org/resource/'
  end

end
