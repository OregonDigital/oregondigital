# This file generated automatically using vocab-fetch from https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld
require 'rdf'
module OregonDigital::Vocabularies
  class OREGONDIGITAL < ::RDF::StrictVocabulary("http://opaquenamespace.org/ns/")

    # Other terms
    property :rangerDistrict, :comment =>
      %(Locations of the Oregon Ranger Districts #waiting for OSU
        definition)
    property :"cco/accessionNumber", :label => 'Accession Number', :comment =>
      %(Identification number assigned to a particular donation or
        acquisition)
    property :artSeries, :label => 'Art Series', :comment =>
      %(In the visual arts, for groups of works by a single artist
        having a specific and purposeful relation among the works.)
    property :awardDate, :label => 'Award Date', :comment =>
      %(Date associated with a grant, competition, or professional
        award.)
    property :boxNumber, :label => 'Box Number', :comment =>
      %(Identifier on the box holding the physical archival item.)
    property :canzonierePoems, :label => 'Canzoniere Poems', :comment =>
      %(Poem numbers from the critical edition of the Canzoniere:
        Petrarca, Francesco. Rerum vulgarium fragmenta. Edizione
        critica di Giuseppe Savoca, Olschki, Firenze, 2008.)
    property :captionTitle, :label => 'Caption Title', :comment =>
      %(Additional title description in caption.)
    property :compassDirection, :label => 'Compass Direction', :comment =>
      %(The horizontal direction expressed as an angular distance
        measured clockwise from compass north.)
    property :contributingInstitution, :label => 'Contributing Institution', :comment =>
      %(A reference to the institutions or administrative units that
        contributed to the creation, management, description, and/or
        dissemination of the digital resource. For example, one
        institution may physically hold the original resource, another
        may perform the digital imaging, and another may create
        metadata.)
    property :conversionSpecifications, :label => 'Conversion Specifications', :comment =>
      %(Describes the process, equipment and specifications used to
        convert the resource into its present format.)
    property :coverDescription, :label => 'Cover Description', :comment =>
      %(Descriptive statement about the external cover or binding of
        an item.)
    property :"cco/creatorDisplay", :label => 'Creator Display', :comment =>
      %(A label identifying the person or corporate body in the work
        or image records by combining the preferred name and
        biographical information.)
    property :dateDigitized, :label => 'Date Digitized', :comment =>
      %(The date the object was initially converted into a digital
        format.)
    property :ethnographic, :label => 'Ethnographic', :comment =>
      %(Descriptive terms related to ethnographic subject matter like
        folklore, ethnomusicology, cultural anthropology, and related
        fields.)
    property :exhibit, :label => 'Exhibit', :comment =>
      %(Curated set or grouping created for a special display or
        exhibit not related to a formal collection.)
    property :"sheetmusic/firstLine", :label => 'First Line', :comment =>
      %(The \'First Line\' data is a direct transcription of the first
        line of lyrics appearing in the song.)
    property :"sheetmusic/firstLineChorus", :label => 'First Line Chorus', :comment =>
      %(The \'first line of chorus\' data is a direct transcription of
        the first line of the chorus \(refrain\) appearing in the
        song.)
    property :folderNumber, :label => 'Folder Number', :comment =>
      %(Identifier on the folder within the box holding the physical
        archival item.)
    property :fullText, :label => 'Full Text', :comment =>
      %(A complete textual representation or transcription of the item
        content.)
    property :"sheetmusic/hostItem", :label => 'Host Item', :comment =>
      %(Identifier of the host item for the constituent unit in a
        vertical relationship. This information allows users to locate
        the physical piece that contains the component part described
        in the record.)
    property :"sheetmusic/instrumentation", :label => 'Instrumentation', :comment =>
      %(A listing of the performing forces called for by a particular
        piece of sheet music, including both voices and external
        instruments.)
    property :"sheetmusic/largerWork", :label => 'Larger Work', :comment =>
      %(The \'title of larger work\' data is used when the item being
        cataloged is known to be one part of a larger work with a
        known title.)
    property :localCollectionID, :label => 'Local Collection ID', :comment =>
      %(Identifier given to a collection by the holding institution.)
    property :localCollectionName, :label => 'Local Collection Name', :comment =>
      %(Title given to a collection by the holding institution.)
    property :militaryBranch, :label => 'Military Branch', :comment =>
      %(Description of the branches of the U.S. military.)
    property :militaryHighestRank, :label => 'Military Highest Rank', :comment =>
      %(Description of highest position held within a branch of the
        U.S. military.)
    property :militaryOccupation, :label => 'Military Occupation', :comment =>
      %(Description of position and role within a branch of the U.S.
        military.)
    property :militaryServiceLocation, :label => 'Military Service Location', :comment =>
      %(Description of the places of service within a branch of the
        U.S. military.)
    property :rightsHolder, :label => 'Rights Holder', :comment =>
      %(Current person or organization who maintains copyright.)
    property :seriesName, :label => 'Series Name', :comment =>
      %(Title of series within collection.)
    property :sourceCondition, :label => 'Source Condition', :comment =>
      %(The physical condition of the source object.)
    property :sportsTeam, :label => 'Sports Team', :comment =>
      %(The official name of the sports or athletics team. A team
        sport includes any sport which involves players working
        together towards a shared objective.)
    property :tgm, :label => 'TGM', :comment =>
      %(Thesaurus of Graphic Materials.)
    property :uoNames, :label => 'University of Oregon Names', :comment =>
      %(For names of people associated with the University of Oregon.)
    property :"cco/viewDate", :label => 'View Date', :comment =>
      %(Includes any date or range of dates associated with the
        creation or production of the image.)
    property :"cco/viewDescription", :label => 'View Description', :comment =>
      %(Describes the spatial, chronological or contextual aspect of
        teh work as captures in the image view.)
    property :contents, :label => 'contents', :comment =>
      %(Defines a relationship between an object and a list of objects
        which make up its parts.)
    property :set, :label => 'set', :comment =>
      %(Defines a relationship between an object and a group or
        collection of objects to which it belongs.)
  end
end
