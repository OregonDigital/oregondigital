# This file generated automatically using vocab-fetch from https://raw.github.com/OregonDigital/opaque_ns/master/opaquenamespace.jsonld
require 'rdf'
module OregonDigital::Vocabularies
  class OREGONDIGITAL < ::RDF::StrictVocabulary("http://opaquenamespace.org/ns/")

    # Other terms
    property :"cco/accessionNumber", :label => 'Accession Number', :comment =>
      %(Identification number assigned to a particular donation or
        acquisition)
    property :"archives/boxNumber", :label => 'Box Number', :comment =>
      %(Identifier on the box holding the physical archival item.)
    property :"archives/collectionIdentifier", :label => 'Collection Identifier', :comment =>
      %(Identifier given to a collection of archival material by the
        holding institution.)
    property :"archives/collectionTitle", :label => 'Collection Title', :comment =>
      %(Title given to a collection of archival material by the
        holding institution.)
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
    property :Cover, :label => 'Cover', :comment =>
      %(An external cover, as on a book, document, or case.)
    property :"cco/creatorDisplay", :label => 'Creator Display', :comment =>
      %(A label identifying the person or corporate body in the work
        or image records by combining the preferred name and
        biographical information.)
    property :exhibit, :label => 'Exhibit', :comment =>
      %(Curated set or grouping created for a special display or
        exhibit not related to a formal collection.)
    property :"archives/folderNumber", :label => 'Folder Number', :comment =>
      %(Identifier on the folder within the box holding the physical
        archival item.)
    property :hasCover, :label => 'Has Cover', :comment =>
      %(Specifies a cover physically attached to the resource.)
    property :sourceCondition, :label => 'Source Condition', :comment =>
      %(The physical condition of the source object.)
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
