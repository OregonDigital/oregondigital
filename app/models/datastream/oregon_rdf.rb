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
    index.as :searchable, :displayable, :symbol, :facetable, :stored_searchable, :sortable
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
  property :contributor, :predicate => RDF::DC11.contributor, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :displayable
  end
  property :arranger, :predicate => OregonDigital::Vocabularies::MARCREL.arr, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :artist, :predicate => OregonDigital::Vocabularies::MARCREL.art, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
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
    index.as :displayable, :facetable
  end
  property :interviewee, :predicate => OregonDigital::Vocabularies::MARCREL.ive, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :interviewer, :predicate => OregonDigital::Vocabularies::MARCREL.ivr, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
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
    index.as :searchable, :displayable
  end
  property :translator, :predicate => OregonDigital::Vocabularies::MARCREL.trl do |index|
    index.as :searchable, :displayable
  end
  property :creatorDisplay, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL['cco/creatorDisplay'] do |index|
    index.as :displayable
  end
  property :collector, :predicate => OregonDigital::Vocabularies::MARCREL.col, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :displayable
  end

  # Descriptions
  property :description, :predicate => RDF::DC.description do |index|
    index.as :searchable, :displayable, :stored_searchable
  end
  property :abstract, :predicate => RDF::DC.abstract do |index|
    index.as :searchable, :displayable
  end
  property :inscription, :predicate => OregonDigital::Vocabularies::VRA.inscription do |index|
    index.as :searchable, :displayable
  end
  property :view, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL['cco/viewDescription'] do |index|
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
  property :objectOrientation, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.objectOrientation do |index|
    index.as :displayable
  end
  property :photographOrientation, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.photographOrientation do |index|
    index.as :displayable
  end
  property :conditionOfSource, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.sourceCondition do |index|    
    index.as :searchable, :displayable
  end
  property :instrumentation, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.instrumentation do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :od_content, :predicate => RDF::URI('http://opaquenamespace.org/ns/contents'), :class_name => GenericAsset do |index|
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
  property :canzonierePoems, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.canzonierePoems do |index|
    index.as :displayable
  end
  property :coverage, :predicate => RDF::DC11.coverage do |index|
    index.as :searchable, :displayable
  end
  property :provenance, :predicate => RDF::DC.provenance do |index|
    index.as :displayable
  end
  property :tableOfContents, :predicate => RDF::DC.tableOfContents do |index|
    index.as :displayable
  end
  property :tribalNotes, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tribalNotes do |index|
    index.as :displayable
  end
  property :acceptedNameUsage, :predicate => RDF::URI('http://rs.tdwg.org/dwc/terms/acceptedNameUsage') do |index|
    index.as :displayable
  end
  property :originalNameUsage, :predicate => RDF::URI('http://rs.tdwg.org/dwc/terms/originalNameUsage') do |index|
    index.as :displayable
  end
  property :specimenType, :predicate => RDF::URI('http://opaquenamespace.org/ns/specimenType') do |index|
    index.as :displayable
  end
  property :temporal, :predicate => RDF::DC.temporal do |index|
    index.as :searchable, :displayable
  end

  # Subjects
  # :lcsubject is controlled subject using multiple vocabs
  property :lcsubject, :predicate => RDF::DC.subject, :class_name => OregonDigital::ControlledVocabularies::Subject do |index|
    index.as :searchable, :facetable, :displayable
  end
  # :subject is for keywords
  property :subject, :predicate => RDF::DC11.subject do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :stateEdition, :predicate => OregonDigital::Vocabularies::VRA.stateEdition do |index|
    index.as :searchable, :displayable
  end
  property :stylePeriod, :predicate => OregonDigital::Vocabularies::VRA.hasStylePeriod, :class_name => OregonDigital::ControlledVocabularies::StylePeriod do |index|
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
  property :sportsTeam, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.sportsTeam do |index|
    index.as :searchable, :displayable
  end
  property :tribalClasses, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tribalClasses do |index|
    index.as :searchable, :displayable
  end
  property :tribalTerms, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tribalTerms do |index|
    index.as :searchable, :displayable
  end


  # Geographics
  property :geobox, :predicate => RDF::URI('https://schema.org/box') do |index|
     index.as :searchable, :displayable
  end
  property :latitude, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#gpsLatitude') do |index|
     index.as :searchable, :displayable
  end
  property :longitude, :predicate => RDF::URI('http://www.w3.org/2003/12/exif/ns#gpsLongitude') do |index|
     index.as :searchable, :displayable
  end
  property :location, :predicate => RDF::DC.spatial, :class_name => OregonDigital::ControlledVocabularies::Geographic do |index|
     index.as :searchable, :facetable, :displayable
  end
  property :streetAddress, :predicate => RDF::URI('http://www.loc.gov/standards/mads/rdf/v1.html#streetAddress') do |index|
    index.as :searchable, :displayable
  end
  property :rangerDistrict, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.rangerDistrict, :class_name => OregonDigital::ControlledVocabularies::Geographic do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :tgn, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tgn, :class_name => OregonDigital::ControlledVocabularies::GettyTGN do |index|
    index.as :searchable, :facetable, :displayable
  end

  # Dates
  property :date, :predicate => RDF::DC.date do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :earliestDate, :predicate => OregonDigital::Vocabularies::VRA.earliestDate do |index|
    index.as :searchable, :displayable
  end
  property :issued, :predicate => RDF::DC.issued do |index|
    index.as :searchable, :displayable
  end
  property :latestDate, :predicate => OregonDigital::Vocabularies::VRA.latestDate do |index|
    index.as :searchable, :displayable
  end
  property :viewDate, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL['cco/viewDate'] do |index|
    index.as :displayable
  end
  property :awardDate, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.awardDate do |index|
    index.as :searchable, :displayable
  end
  property :collectedDate, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.collectedDate do |index|
    index.as :displayable
  end

  # Identifiers
  property :identifier, :predicate => RDF::DC.identifier do |index|
    index.as :searchable, :displayable
  end
  property :itemLocator, :predicate => OregonDigital::Vocabularies::HOLDING.label do |index|
    index.as :searchable, :displayable
  end
  property :accessionNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL['cco/accessionNumber'] do |index|
    index.as :searchable, :displayable
  end
  property :lccn, :predicate => OregonDigital::Vocabularies::BIBFRAME.lccn do |index|
    index.as :searchable, :displayable
  end
  property :barcode, :predicate => OregonDigital::Vocabularies::BIBFRAME.barcode do |index|
    index.as :displayable
  end

  # Rights
  property :rights, :predicate => RDF::DC.rights, :class_name => OregonDigital::ControlledVocabularies::RightsStatement do |index|
    index.as :searchable, :displayable, :facetable
  end
  property :rights_statement, :predicate => RDF::DC11.rights do |index|
    index.as :searchable, :displayable, :facetable
  end
  property :rightsHolder, :predicate => RDF::URI('http://opaquenamespace.org/rights/rightsHolder') do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :dcRightsHolder, :predicate => RDF::DC.rightsHolder do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :useRestrictions, :predicate => OregonDigital::Vocabularies::ARCHIVESHUB.useRestrictions do |index|
    index.as :searchable, :displayable
  end
  property :accessRestrictions, :predicate => OregonDigital::Vocabularies::ARCHIVESHUB.accessRestrictions do |index|
    index.as :searchable, :displayable
  end
  property :license, :predicate => OregonDigital::Vocabularies::CCREL.license do |index|
    index.as :displayable
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
    index.as :searchable, :facetable, :displayable
  end
  property :placeOfPublication, :predicate => OregonDigital::Vocabularies::MARCREL.pup do |index|
    index.as :displayable
  end
  property :od_repository, :predicate => OregonDigital::Vocabularies::MARCREL.rps, :class_name => OregonDigital::ControlledVocabularies::Repos do |index|
    index.as :searchable, :facetable, :displayable
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
  property :seriesNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.seriesNumber do |index|
    index.as :displayable
  end
  property :boxNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.boxNumber do |index|
    index.as :searchable, :displayable
  end
  property :folderNumber, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.folderNumber do |index|
    index.as :searchable, :displayable
  end
  property :folderName, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.folderName do |index|
    index.as :searchable, :displayable
  end

  # Types
  property :type, :predicate => RDF::DC.type, :class_name => OregonDigital::ControlledVocabularies::DCMIType do |index|
    index.as :facetable, :displayable
  end

  # Formats
  property :format, :predicate => RDF::DC.format, :class_name => OregonDigital::ControlledVocabularies::Format do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :physicalExtent, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1/#physicalExtent') do |index|
    index.as :displayable
  end
  property :extent, :predicate => RDF::DC.extent do |index|
    index.as :searchable, :displayable
  end
  property :measurements, :predicate => OregonDigital::Vocabularies::VRA.measurements do |index|
    index.as :displayable
  end
  property :material, :predicate => OregonDigital::Vocabularies::VRA.material do |index|
    index.as :searchable, :displayable
  end
  property :support, :predicate => OregonDigital::Vocabularies::VRA.support do |index|
    index.as :searchable, :displayable
  end
  property :technique, :predicate => OregonDigital::Vocabularies::VRA.hasTechnique do |index|
    index.as :searchable, :displayable
  end

  # Groupings
  property :set, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.set, :class_name => "GenericCollection" do |index|
    index.as :searchable, :facetable, :displayable
  end

  # Relations
  property :relation, :predicate => RDF::DC.relation do |index|
    index.as :displayable
  end
  property :largerWork, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.largerWork do |index|
    index.as :searchable, :displayable
  end
  property :artSeries, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.artSeries do |index|
    index.as :searchable, :displayable
  end
  property :hostItem, :predicate => OregonDigital::Vocabularies::SHEETMUSIC.hostItem do |index|
    index.as :displayable
  end
  property :hasPart, :predicate => RDF::DC.hasPart do |index|
    index.as :displayable
  end
  property :isPartOf, :predicate => RDF::DC.isPartOf do |index|
    index.as :searchable, :displayable
  end
  property :hasVersion, :predicate => RDF::DC.hasVersion do |index|
    index.as :displayable
  end
  property :isVersionOf, :predicate => RDF::DC.isVersionOf do |index|
    index.as :displayable
  end
  property :findingAid, :predicate => RDF::URI('http://lod.xdams.org/reload/oad/has_findingAid') do |index|
    index.as :displayable
  end

  # Administrative
  property :institution, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.contributingInstitution, :class_name => OregonDigital::ControlledVocabularies::Organization do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :conversion, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.conversionSpecifications
  property :dateDigitized, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.dateDigitized
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
  property :tribalStatus, :predicate => OregonDigital::Vocabularies::OREGONDIGITAL.tribalStatus do |index|
    index.as :searchable, :displayable
  end
  property :submissionDate, :predicate => RDF::DC.dateSubmitted do |index|
    index.as :searchable, :displayable
  end
  property :replacesUrl, :predicate => RDF::DC.replaces do |index|
    index.as :symbol
  end

  # Schema.org
  property :citation, :predicate => RDF::SCHEMA.citation do |index|
    index.as :searchable, :displayable
  end
  property :editor, :predicate => RDF::SCHEMA.editor, :class_name => OregonDigital::ControlledVocabularies::Creator do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :numberOfPages, :predicate => RDF::SCHEMA.numberOfPages do |index|
    index.as :facetable, :displayable
  end
  property :event, :predicate => RDF::SCHEMA.event do |index|
    index.as :facetable, :displayable
  end

  # Darwin Core
  property :taxonClass, :predicate => OregonDigital::Vocabularies::DWC.class, :class_name => OregonDigital::ControlledVocabularies::SciClass do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :order, :predicate => OregonDigital::Vocabularies::DWC.order do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :family, :predicate => OregonDigital::Vocabularies::DWC.family do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :genus, :predicate => OregonDigital::Vocabularies::DWC.genus, :class_name => OregonDigital::ControlledVocabularies::SciGenus do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :phylum, :predicate => OregonDigital::Vocabularies::DWC.phylum, :class_name => OregonDigital::ControlledVocabularies::SciPhylum do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :higherClassification, :predicate => OregonDigital::Vocabularies::DWC.higherClassification do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :commonNames, :predicate => OregonDigital::Vocabularies::DWC.vernacularName, :class_name => OregonDigital::ControlledVocabularies::SciCommon do |index|
    index.as :searchable, :facetable, :displayable
  end
  property :identificationVerificationStatus, :predicate => OregonDigital::Vocabularies::DWC.identificationVerificationStatus do |index|
    index.as :searchable, :facetable, :displayable
  end

  # PREMIS
  property :preservation, :predicate => OregonDigital::Vocabularies::PREMIS.hasOriginalName
  property :hasFixity, :predicate => OregonDigital::Vocabularies::PREMIS.hasFixity

  # MODS RDF
  property :locationCopySublocation, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1/#locationCopySublocation') do |index|
    index.as :displayable
  end
  property :locationCopyShelfLocator, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1/#locationCopyShelfLocator') do |index|
    index.as :displayable
  end
  property :note, :predicate => RDF::URI('http://www.loc.gov/standards/mods/modsrdf/v1/#note') do |index|
    index.as :displayable
  end

  # VRA
  property :culturalContext, :predicate => OregonDigital::Vocabularies::VRA.culturalContext do |index|
    index.as :displayable
  end
  property :idCurrentRepository, :predicate => OregonDigital::Vocabularies::VRA.idCurrentRepository do |index|
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
  property :formOfWork, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/w/#formOfWork.en') do |index|
    index.as :displayable
  end
  property :fileSize, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#fileSize.en') do |index|
    index.as :displayable
  end
  property :layout, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#layout.en') do |index|
    index.as :displayable
  end
  property :containedInManifestation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#containedInManifestation.en') do |index|
    index.as :displayable
  end
  property :modeOfIssuance, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#modeOfIssuance.en') do |index|
    index.as :displayable
  end
  property :placeOfProduction, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#placeOfProduction.en') do |index|
    index.as :displayable
  end
  property :descriptionOfManifestation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/m/#descriptionOfManifestation.en') do |index|
    index.as :displayable
  end
  property :colourContent, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/e/#colourContent.en') do |index|
    index.as :displayable
  end
  property :biographicalInformation, :predicate => RDF::URI('http://www.rdaregistry.info/Elements/a/#biographicalInformation.en') do |index|
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


  def to_solr(solr_doc = Hash.new)
    solr_doc = index_terms(solr_doc)
    solr_doc = index_coordinates(solr_doc)
  end

  def index_coordinates(solr_doc = Hash.new)
    latitude = resource.get_values(:latitude).first
    longitude = resource.get_values(:longitude).first
    if latitude && longitude
      prefix = apply_prefix(:coordinates)
      solr_doc["#{prefix}_llsim".to_sym] = ["#{latitude},#{longitude}"]
    end
    solr_doc
  end

  def index_terms(solr_doc = Hash.new)
    fields.each do |field_key, field_info|
      values = resource.get_values(field_key).map{|x| x.respond_to?(:resource) ? x.resource : x}
      Array.wrap(values).each do |val|
        val = val.to_s if val.kind_of? ::RDF::URI
        val = val.solrize if val.kind_of? ActiveFedora::Rdf::Resource
        Array.wrap(val).each do |solr_val|
          new_key = field_key
          if solr_val.kind_of?(Hash)
            solr_val.each do |k, v|
              new_key = "#{field_key}_#{k}"
              self.class.create_and_insert_terms(apply_prefix(new_key), v, field_info[:behaviors], solr_doc)
            end
            next
          end
          self.class.create_and_insert_terms(apply_prefix(new_key), solr_val, field_info[:behaviors], solr_doc)
        end
      end
    end
    solr_doc
  end

  def self.default_attributes
    super.merge(:controlGroup => 'M', :mimeType => 'application/n-triples')
  end

  def from_solr(solr_doc)
    @datastream_content = ""
    relevant_values = solr_doc.select{|k, v| k.start_with?(dsid.underscore)}.map{|k, v| {k.split("__").last.split("_").reverse.drop(1).reverse.join("_") => v}}.inject(&:merge)
    relevant_values.each do |k, v|
      if k.start_with?("od_content")
        @od_content = v.map do |x|
          pid = "oregondigital:#{OregonDigital::IdService.noidify(x)}"
          begin
            ActiveFedora::Base.load_instance_from_solr(pid)
          rescue ActiveFedora::ObjectNotFoundError
            OregonDigital::RDF::ObjectResource.new(pid)
          end
        end
      end
      meth_name = :"#{k}="
      v = coerce_to_uri(v)
      self.send(meth_name, v) if respond_to?(meth_name)
    end
  end

  def coerce_to_uri(value)
    value = Array(value)
    value.each_with_index do |v,i|
      next unless v.start_with?("http")
      value[i] = RDF::URI(v)
    end
    value
  end

  alias_method :orig_od_content, :od_content
  def od_content
    return @od_content if @od_content
    orig_od_content
  end

end
