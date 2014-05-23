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
  property :alternative, :predicate => RDF::DC.alternative do |index|
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
  property :lcsubject, :predicate => RDF::DC.subject, :class_name => OregonDigital::ControlledVocabularies::Subject do |index|
      index.as :searchable, :facetable, :displayable
 end
  property :subject, :predicate => RDF::DC11.subject do |index|
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
  property :coverage, :predicate => RDF::DC11.coverage do |index|
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
    index.as :searchable, :displayable
  end
  property :submissionDate, :predicate => RDF::DC.dateSubmitted do |index|
    index.as :searchable, :displayable
  end
  property :issued, :predicate => RDF::DC.issued do |index|
    index.as :searchable, :displayable
  end
  property :date, :predicate => RDF::DC.date do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :publisher, :predicate => RDF::DC.publisher do |index|
    index.as :searchable, :facetable,  :displayable
  end
  property :format, :predicate => RDF::DC.format,  :class_name => OregonDigital::ControlledVocabularies::Format do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :localCollection, :predicate => RDF::DC.isPartOf do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :hasPart, :predicate => RDF::DC.hasPart do |index|
    index.as :displayable
  end
  property :provenance, :predicate => RDF::DC.provenance do |index|
    index.as :displayable
  end
  property :replacesUrl, :predicate => RDF::DC.replaces do |index|
    index.as :symbol
  end
  
  # MARCRel
  property :photographer, :predicate => OregonDigital::Vocabularies::MARCREL.pht do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :donor, :predicate => OregonDigital::Vocabularies::MARCREL.dnr do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :composer, :predicate => OregonDigital::Vocabularies::MARCREL.cmp, :class_name => OregonDigital::ControlledVocabularies::LCNames do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :lyricist, :predicate => OregonDigital::Vocabularies::MARCREL.lyr, :class_name => OregonDigital::ControlledVocabularies::LCNames do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :arranger, :predicate => OregonDigital::Vocabularies::MARCREL.arr, :class_name => OregonDigital::ControlledVocabularies::LCNames do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :placeOfPublication, :predicate => OregonDigital::Vocabularies::MARCREL.pup do |index|
    index.as :displayable
  end
  property :copyrightClaimant, :predicate => OregonDigital::Vocabularies::MARCREL.cpc do |index|
    index.as :displayable
  end
  property :illustrator, :predicate => OregonDigital::Vocabularies::MARCREL.ill do |index|
    index.as :displayable
  end
  property :printMaker, :predicate => OregonDigital::Vocabularies::MARCREL.prm do |index|
    index.as :displayable
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
  
  # MODS RDF
  property :physicalExtent, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#physicalExtent') do |index|
    index.as :displayable
  end
  property :locationCopySublocation, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#locationCopySublocation') do |index|
    index.as :displayable
  end
  property :locationCopyShelfLocator, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#locationCopyShelfLocator') do |index|
    index.as :displayable
  end
  property :locationCopyShelfLocator, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#note') do |index|
    index.as :displayable
  end
  
  # CCO
  property :view, :predicate => RDF::URI('http://opaquenamespace.org/ns/cco/viewDescription') do |index|
    index.as :displayable
  end

  # VRA
  property :earliestDate, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/earliestDate') do |index|
    index.as :searchable, :displayable
  end
  property :latestDate, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/latestDate') do |index|
    index.as :searchable, :displayable
  end
  property :culturalContext, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/culturalContext') do |index|
    index.as :displayable
  end
  property :measurements, :predicate => RDF::URI('http://www.loc.gov/standards/vracrore/vocab/measurements') do |index|
    index.as :displayable
  end
  property :inscription, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/inscription') do |index|
    index.as :searchable, :displayable
  end
  property :workType, :predicate => RDF.type, :class_name => OregonDigital::ControlledVocabularies::AAT do |index|
    index.as :searchable, :facetable, :displayable
  end

# Oregon Digital
  property :set, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.set, :class_name => "GenericCollection" do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :institution, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.contributingInstitution, :class_name => OregonDigital::ControlledVocabularies::Organization do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :conversion, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.conversionSpecification
  property :captionTitle, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.captionTitle do |index|
    index.as :searchable, :displayable
  end
  property :cover, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.cover do |index|
    index.as :searchable, :displayable
  end
  property :exhibit, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.exhibit do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :dateDigitized, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.dateDigitized

# Oregon Digital Rights
  property :rightsHolder, :predicate => RDF::URI('http://opaquenamespace.org/rights/rightsHolder') do |index|
    index.as :searchable, :facetable, :displayable
  end

# Oregon Digital Sheet Music
  property :instrumentation, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.instrumentation do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :firstLine, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.firstLine do |index|
    index.as :searchable, :displayable
  end 
  property :firstLineChorus, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.firstLineChorus do |index|
    index.as :searchable, :displayable
  end 
  property :largerWork, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.largerWork do |index|
    index.as :searchable, :displayable
  end   
  property :hostItem, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.hostItem do |index|
    index.as  :displayable
  end

  def to_solr(solr_doc = Hash.new)
    fields.each do |field_key, field_info|
      values = resource.get_values(field_key).map{|x| x.respond_to?(:resource) ? x.resource : x}
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
