class Datastream::OregonRDF < OregonDigital::QuadResourceDatastream
  # TODO: use an http URI instead of the PID as a subject
  # rdf_subject { |ds| Utils.rdf_subject(ds.pid) }
  include ActiveFedora::Crosswalks::Crosswalkable
  include OregonDigital::RDF::DeepFetch

  def self.resource_class
    OregonDigital::RDF::ObjectResource
  end

  # Titles
  property :title, :predicate => RDF::DC.title do |index|
    index.as :searchable, :displayable
  end
  property :alternative, :predicate => RDF::DC.alternative do |index|
    index.as :searchable, :displayable
  end
  property :captionTitle, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.captionTitle do |index|
    index.as :searchable, :displayable
  end
  property :tribalTitle, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tribalTitle do |index|
    index.as :searchable, :displayable
  end

  # Creators
  property :creator, :predicate => RDF::DC11.creator, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :contributor, :predicate => RDF::DC11.contributor, :class_name => OregonDigital::ControlledVocabularies::Creator  do |index|
    index.as :searchable, :displayable
  end
  property :arranger, :predicate => OregonDigital::Vocabularies::MARCREL.arr, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :artist, :predicate => OregonDigital::Vocabularies::MARCREL.art, :class_name => OregonDigital::ControlledVocabularies::Creator ido |index|
    index.as :searchable, :facetable, :displayable
  end
  property :author, :predicate => OregonDigital::Vocabularies::MARCREL.aut, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :cartographer, :predicate => OregonDigital::Vocabularies::MARCREL.ctg do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :composer, :predicate => OregonDigital::Vocabularies::MARCREL.cmp, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :donor, :predicate => OregonDigital::Vocabularies::MARCREL.dnr do |index|
    index.as :searchable, :displayable
  end
  property :illustrator, :predicate => OregonDigital::Vocabularies::MARCREL.ill, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :displayable, :facetable, :displayable
  end
  property :interviewee, :predicate => OregonDigital::Vocabularies::MARCREL.ive do |index|
    index.as :searchable, :displayable
  end
  property :interviewer, :predicate => OregonDigital::Vocabularies::MARCREL.ivr do |index|
    index.as :searchable, :displayable
  end
  property :lyricist, :predicate => OregonDigital::Vocabularies::MARCREL.lyr, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :photographer, :predicate => OregonDigital::Vocabularies::MARCREL.pht, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :printMaker, :predicate => OregonDigital::Vocabularies::MARCREL.prm do |index|
    index.as :displayable
  end
  property :scribe, :predicate => OregonDigital::Vocabularies::MARCREL.scr do |index|
    index.as :searchable, :displayable
  end
  property :transcriber, :predicate => OregonDigital::Vocabularies::MARCREL.trc do |index|
    index.as :displayable
  end
  property :creatorDisplay, :predicate => RDF::URI('http://opaquenamespace.org/ns/cco/creatorDisplay') do |index|
    index.as :displayable
  end

  # Descriptions
  property :description, :predicate => RDF::DC.description do |index|
    index.as :searchable, :displayable
  end
  property :abstract, :predicate => RDF::DC.abstract do |index|
    index.as :searchable, :displayable
  end
  property :inscription, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/inscription') do |index|
    index.as :searchable, :displayable
  end
  property :artSeries, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.artSeries do |index|
    index.as :searchable, :displayable
  end
  property :view, :predicate => RDF::URI('http://opaquenamespace.org/ns/cco/viewDescription') do |index|
    index.as :displayable
  end
  property :firstLine, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.firstLine do |index|
    index.as :searchable, :displayable
  end
  property :firstLineChorus, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.firstLineChorus do |index|
    index.as :searchable, :displayable
  end
  property :compassDirection, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.compassDirection do |index|
    index.as :displayable
  end
  property :conditionOfSource, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.sourceCondition do |index|
    index.as :searchable, :displayable
  end
  property :instrumentation, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.instrumentation do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :od_content, :predicate => RDF::URI('http://opaquenamespace.org/ns/contents'), :class_name => OregonDigital::RDF::List do |index|
    index.as :symbol
  end
  property :militaryServiceLocation, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.militaryServiceLocation do |index|
    index.as :searchable, :displayable
  end
  property :militaryHighestRank, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.militaryHighestRank do |index|
    index.as :searchable, :displayable
  end
  property :militaryOccupation, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.militaryOccupation do |index|
    index.as :searchable, :displayable
  end
  property :cover, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.coverDescription do |index|
    index.as :searchable, :displayable
  end
  property :largerWork, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.largerWork do |index|
    index.as :searchable, :displayable
  end
  property :hostItem, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.hostItem do |index|
    index.as  :displayable
  end

  # Subjects
  property :lcsubject, :predicate => RDF::DC.subject, :class_name => OregonDigital::ControlledVocabularies::Subject do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :subject, :predicate => RDF::DC11.subject do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :stateEdition, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/stateEdition') do |index|
    index.as :searchable, :displayable
  end
  property :stylePeriod, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/stylePeriod'), :class_name => OregonDigital::ControlledVocabularies::StylePeriod do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :workType, :predicate => RDF.type, :class_name => OregonDigital::ControlledVocabularies::WorkType do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :militaryBranch, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.militaryBranch, :class_name => OregonDigital::ControlledVocabularies::Subject do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :ethnographicTerm, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.ethnographic, :class_name => OregonDigital::ControlledVocabularies::Ethnog do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :person, :predicate => RDF::URI('http://opaquenamespace.org/ns/people'), :class_name => OregonDigital::ControlledVocabularies::People do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :sportsTeam, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.sportsTeam do |index|
    index.as :searchable, :displayable
  end

  # Geographics
  property :location, :predicate => RDF::DC.spatial, :class_name => OregonDigital::ControlledVocabularies::Geographic do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :streetAddress, :predicate => RDF::URI('http://www.loc.gov/standards/mads/rdf/v1.html#streetAddress') do |index|
    index.as :searchable, :displayable
  end
  property :rangerDistrict, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.rangerDistrict, :class_name => OregonDigital::ControlledVocabularies::Geographic do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :tgn, :predicate => RDF::URI('http://opaquenamespace.org/ns/tgn'), :class_name => OregonDigital::ControlledVocabularies::GettyTGN do |index|
    index.as :searchable, :facetable, :displayable
  end

  # Dates
  property :date, :predicate => RDF::DC.date do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :dateDigitized, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.dateDigitized
  property :earliestDate, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/earliestDate') do |index|
    index.as :searchable, :displayable
  end
  property :issued, :predicate => RDF::DC.issued do |index|
    index.as :searchable, :displayable
  end
  property :latestDate, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/latestDate') do |index|
    index.as :searchable, :displayable
  end
  property :viewDate, :predicate => RDF::URI('http://opaquenamespace.org/ns/cco/viewDate') do |index|
    index.as :displayable
  end
  property :awardDate, :predicate => RDF::URI('http://opaquenamespace.org/ns/cco/awardDate') do |index|
    index.as :searchable, :displayable
  end

  # Identifiers
  property :identifier, :predicate => RDF::DC.identifier do |index|
    index.as :searchable, :displayable
  end
  property :itemLocator, :predicate => OregonDigital::Vocabularies::HOLDING.label do |index|
    index.as :displayable
  end
  property :canzonierePoems, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.canzonierePoems do |index|
    index.as :displayable
  end
  property :accessionNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL['cco/accessionNumber'] do |index|
    index.as :searchable, :displayable
  end

  # Rights
  property :rights, :predicate => RDF::DC.rights, :class_name => OregonDigital::ControlledVocabularies::RightsStatement do |index|
    index.as :displayable
  end
  property :rightsHolder, :predicate => RDF::URI('http://opaquenamespace.org/rights/rightsHolder') do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :copyrightClaimant, :predicate => OregonDigital::Vocabularies::MARCREL.cpc do |index|
    index.as :displayable
  end

  # Publishing / Source
  property :source, :predicate => RDF::DC.source do |index|
    index.as :displayable
  end
  property :language, :predicate => RDF::DC.language, :class_name => OregonDigital::ControlledVocabularies::Language do |index|
    index.as :displayable, :facetable
  end
  property :publisher, :predicate => RDF::DC.publisher do |index|
    index.as :searchable, :facetable,  :displayable
  end
  property :placeOfPublication, :predicate => OregonDigital::Vocabularies::MARCREL.pup do |index|
    index.as :displayable
  end
  property :od_repository, :predicate => OregonDigital::Vocabularies::MARCREL.rps, :class_name => OregonDigital::ControlledVocabularies::Repos do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :isPartOf, :predicate => RDF::DC.isPartOf do |index|
    index.as :searchable, :displayable
  end
  property :localCollectionID, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.localCollectionID do |index|
    index.as :searchable, :displayable
  end
  property :localCollectionName, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.localCollectionName, :class_name => OregonDigital::ControlledVocabularies::LocalCollection do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :seriesName, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.seriesName do |index|
    index.as :searchable, :displayable
  end
  property :boxNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.boxNumber do |index|
    index.as :searchable, :displayable
  end
  property :folderNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.folderNumber do |index|
    index.as :searchable, :displayable
  end
  property :folderName, :predicate => RDF::URI('http://opaquenamespace.org/ns/folderName') do |index|
    index.as :searchable, :displayable
  end

  # Types
  property :type, :predicate => RDF::DC.type, :class_name => OregonDigital::ControlledVocabularies::DCMIType do |index|
    index.as :facetable, :displayable
  end

  # Formats
  property :format, :predicate => RDF::DC.format,  :class_name => OregonDigital::ControlledVocabularies::Format do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :physicalExtent, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#physicalExtent') do |index|
    index.as :displayable
  end
  property :measurements, :predicate => RDF::URI('http://www.loc.gov/standards/vracrore/vocab/measurements') do |index|
    index.as :displayable
  end
  property :materials, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/materials') do |index|
    index.as :searchable, :displayable
  end
  property :support, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/support') do |index|
    index.as :searchable, :displayable
  end
  property :technique, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/technique') do |index|
    index.as :searchable, :displayable
  end

  # Groupings
  property :set, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.set, :class_name => "GenericCollection" do |index|
    index.as :searchable, :facetable, :displayable
  end

  # Relations  

  # Administrative
  property :institution, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.contributingInstitution, :class_name => OregonDigital::ControlledVocabularies::Organization do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :conversion, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.conversionSpecifications
  property :created, :predicate => RDF::DC.created do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :modified, :predicate => RDF::DC.modified do |index|
    index.as :searchable, :displayable
  end
  property :exhibit, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.exhibit do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :fullText, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.fullText do |index|
    index.as :searchable, :displayable
  end
  property :submissionDate, :predicate => RDF::DC.dateSubmitted do |index|
    index.as :searchable, :displayable
  end
  property :replacesUrl, :predicate => RDF::DC.replaces do |index|
    index.as :symbol
  end

  # TODO: Are we using these?  If not, ditch them!  If so, they need to be in
  # the data dictionary document!

  property :coverage, :predicate => RDF::DC11.coverage do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :hasPart, :predicate => RDF::DC.hasPart do |index|
    index.as :displayable
  end
  property :provenance, :predicate => RDF::DC.provenance do |index|
    index.as :displayable
  end

  # Schema.org
  property :citation, :predicate => RDF::SCHEMA.citation do |index|
    index.as :searchable, :displayable
  end
  property :editor, :predicate => RDF::SCHEMA.editor do |index|
    index.as :searchable, :displayable
  end
  property :numberOfPages, :predicate => RDF::SCHEMA.numberOfPages do |index|
    index.as :facetable, :displayable
  end
  property :event, :predicate => RDF::SCHEMA.event do |index|
    index.as :facetable, :displayable
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
  property :locationCopySublocation, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#locationCopySublocation') do |index|
    index.as :displayable
  end
  property :locationCopyShelfLocator, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#locationCopyShelfLocator') do |index|
    index.as :displayable
  end
  property :note, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1#note') do |index|
    index.as :displayable
  end
  
  # VRA
  property :culturalContext, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/culturalContext') do |index|
    index.as :displayable
  end
  property :medium, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/medium') do |index|
    index.as :searchable, :displayable
  end
  property :culture, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/culture') do |index|
    index.as :searchable, :displayable
  end
  property :idCurrentRepository, :predicate => RDF::URI('http://www.loc.gov/standards/vracore/vocab/idCurrentRepository') do |index|
    index.as :searchable, :displayable
  end

  # EXIF
  property :imageWidth, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#width') do |index|
    index.as :displayable
  end
  property :imageHeight, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#height') do |index|
    index.as :displayable
  end
  property :imageResolution, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#resolution') do |index|
    index.as :displayable
  end
  property :imageOrientation, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#orientation') do |index|
    index.as :displayable
  end
  property :colorSpace, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#colorSpace') do |index|
    index.as :displayable
  end

  # RDA
  property :formOfWork, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/w/formOfWork.en') do |index|
    index.as :displayable
  end
  property :fileSize, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/fileSize.en') do |index|
    index.as :displayable
  end
  property :layout, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/layout.en') do |index|
    index.as :displayable
  end
  property :containedInManifestation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/containedInManifestation.en') do |index|
    index.as :displayable
  end
  property :modeOfIssuance, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/modeOfIssuance.en') do |index|
    index.as :displayable
  end
  property :placeOfProduction, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/placeOfProduction.en') do |index|
    index.as :displayable
  end
  property :descriptionOfManifestation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/descriptionOfManifestation.en') do |index|
    index.as :displayable
  end
  property :colourContent, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/e/colourContent.en') do |index|
    index.as :displayable
  end
  property :biographicalInformation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/a/biographicalInformation.en') do |index|
    index.as :displayable
  end

  # SWPO
  property :containedInJournal, :predicate => RDF::URI('http://sw-portal.deri.org/ontologies/swportal#containedInJournal') do |index|
    index.as :displayable
  end
  property :isVolume, :predicate => RDF::URI('http://sw-portal.deri.org/ontologies/swportal#isVolume') do |index|
    index.as :displayable
  end
  property :hasNumber, :predicate => RDF::URI('http://sw-portal.deri.org/ontologies/swportal#hasNumber') do |index|
    index.as :displayable
  end

  # MISC
  property :findingAid, :predicate => RDF::URI('http://lod.xdams.org/reload/oad/has_findingAid') do |index|
    index.as :displayable
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
