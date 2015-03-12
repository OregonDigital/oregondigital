# This file generated automatically using vocab-fetch from http://data.archiveshub.ac.uk/def/
require 'rdf'
module OregonDigital::Vocabularies
  class ARCHIVESHUB < ::RDF::StrictVocabulary("http://data.archiveshub.ac.uk/def/")

    # Class definitions
    property :ArchivalResource, :label => 'Archival Resource', :comment =>
      %(Recorded information in any form or medium, created or
        received and maintained, by an organization or person\(s\) in
        the transaction of business or the conduct of affairs, and
        maintained for its long-term research value. An archival
        resource may be an individual item, such as a letter or
        photograph, or \(more commonly\) some aggregation of such
        items managed and described as a unit.)
    property :BiographicalHistory, :label => 'Biographical History', :comment =>
      %(A narrative or chronology that places archival materials in
        context by providing information about their creator\(s\). A
        finding aid may contain several such narratives or
        chronologies pertaining to different archival materials and
        their creators.)
    property :Creation, :label => 'Creation', :comment =>
      %(An event that resulted in the creation or accumulation of an
        archival resource.)
    property :EAD, :label => 'EAD Document', :comment =>
      %(A document conforming to the Encoded Archival Description
        standard.)
    property :Extent, :label => 'Extent', :comment =>
      %(The size of an archival resource.)
    property :Family, :label => 'Family', :comment =>
      %(A group of people affiliated by consanguinity, affinity, or
        co-residence.)
    property :FindingAid, :label => 'Finding Aid', :comment =>
      %(A document describing an archival resource.)
    property :Floruit, :label => 'Floruit', :comment =>
      %(An event corresponding to the activity of an agent.)
    property :Function, :label => 'Function', :comment =>
      %(A sphere of activity or process.)
    property :GenreForm, :label => 'Genre or Form', :comment =>
      %(A category of archival material, defined either by style or
        technique of intellectual content, order of information or
        object function, or physical characteristics.)
    property :Level, :label => 'Level', :comment =>
      %(An indicator of the part of an archival collection constituted
        by an archival resource, whether it is the whole collection or
        a sub-section of it.)
    property :Repository, :label => 'Repository', :comment =>
      %(An institution or agency responsible for providing access to
        archival materials.)

    # Property definitions
    property :accessProvidedBy, :label => 'Access Provided By', :comment =>
      %(An agent that provides access to the resource.)
    property :accessRestrictions, :label => 'Access Restrictions', :comment =>
      %(Access Restrictions)
    property :accruals, :label => 'Accruals', :comment =>
      %(Accruals)
    property :acquisitions, :label => 'Acquisitions', :comment =>
      %(Acquisitions)
    property :administers, :label => 'Administers', :comment =>
      %(A resource which the agent manages.)
    property :alternateFormsAvailable, :label => 'Alternate Forms Available', :comment =>
      %(Alternate Forms Available)
    property :appraisal, :label => 'Appraisal', :comment =>
      %(Appraisal)
    property :archbox, :label => 'Archival Box', :comment =>
      %(A number of archival boxes)
    property :associatedWith, :label => 'Associated With', :comment =>
      %(A concept adjudged by a cataloguer to have an association with
        an archival resource which they consider useful for the
        purposes of discovering that resource.)
    property :bibliography, :label => 'Bibliography', :comment =>
      %(Bibliography)
    property :body, :label => 'Body', :comment =>
      %(A literal representation of the content of the document.)
    property :countryCode, :label => 'Country Code', :comment =>
      %(The ISO 3166-1 code for the country of the repository.)
    property :cubicmetre, :label => 'Cubic Metre', :comment =>
      %(A number of cubic metres)
    property :custodialHistory, :label => 'Custodial History', :comment =>
      %(Custodial History)
    property :dateCreatedAccumulatedString, :label => 'Date created or accumulated', :comment =>
      %(The date, represented as a string, of a time interval during
        which the archival resource was created or accumulated.)
    property :dateCreatedAccumulated, :label => 'Date created or accumulated', :comment =>
      %(The date, represented as a typed literal, of a time interval
        during which the archival resource was created or accumulated.)
    property :dateCreatedAccumulatedEnd, :label => 'Date created or accumulated (end)', :comment =>
      %(The end date, represented as a typed literal, of a time
        interval during which the archival resource was created or
        accumulated.)
    property :dateCreatedAccumulatedStart, :label => 'Date created or accumulated (start)', :comment =>
      %(The start date, represented as a typed literal, of a time
        interval during which the archival resource was created or
        accumulated.)
    property :dateBirth, :label => 'Date of Birth', :comment =>
      %(The date of birth of the person.)
    property :dateDeath, :label => 'Date of Death', :comment =>
      %(The date of death of the person.)
    property :dates, :label => 'Dates', :comment =>
      %(Dates)
    property :encodedAs, :label => 'Encoded As', :comment =>
      %(An EAD document that is an encoding of the archival finding
        aid.)
    property :encodingOf, :label => 'Encoding Of', :comment =>
      %(An archival finding aid of which the EAD document is an
        encoding.)
    property :envelope, :label => 'Envelope', :comment =>
      %(A number of envelopes)
    property :epithet, :label => 'Epithet', :comment =>
      %(Epithet)
    property :extent, :label => 'Extent', :comment =>
      %(The size of the archival resource.)
    property :file, :label => 'File', :comment =>
      %(A number of files)
    property :folder, :label => 'Folder', :comment =>
      %(A number of folders)
    property :forename, :label => 'Forename', :comment =>
      %(The forename of a person who is the focus of the concept)
    property :hasBiographicalHistory, :label => 'Has Biographical History', :comment =>
      %(A narrative or chronology that places archival materials in
        context by providing information about their creator\(s\).)
    property :isAdministeredBy, :label => 'Is Administered By', :comment =>
      %(An agent that manages the resource.)
    property :isBiographicalHistoryFor, :label => 'Is Biographical History For', :comment =>
      %(An archival resource that the narrative or chronology places
        in context by providing information about their creator\(s\).)
    property :isMaintenanceAgencyOf, :label => 'Is Maintenance Agency Of', :comment =>
      %(An archival finding aid for which the repository is
        responsible for the maintenance.)
    property :isOriginationOf, :label => 'Is Origination Of', :comment =>
      %(An archival resource for which the agent is responsible for
        the creation or accumulation.)
    property :isPublisherOf, :label => 'Is Publisher Of', :comment =>
      %(A resource which the agent makes available.)
    property :isRepresentedBy, :label => 'Is Represented By', :comment =>
      %(A resource which represents the archival resource, such as an
        image of a text page, a transcription of text, an audio or
        video clip, or an aggregation of such resources.)
    property :isRepresentedBy, :label => 'Is Represented By', :comment =>
      %(An archival resourcce represented by the resource.)
    property :item, :label => 'Item', :comment =>
      %(A number of items)
    property :level, :label => 'Level', :comment =>
      %(An indicator of the part of an archival collection constituted
        by an archival resource.)
    property :location, :label => 'Location', :comment =>
      %(Location)
    property :locationOfOriginals, :label => 'Location of Originals', :comment =>
      %(Location of Originals)
    property :maintenanceAgency, :label => 'Maintenance Agency', :comment =>
      %(A repository responsible for the maintenance of the archival
        finding aid.)
    property :maintenanceAgencyCode, :label => 'Maintenance Agency Code', :comment =>
      %(The ISO 15511 code for the repository.)
    property :members, :label => 'Members', :comment =>
      %(Members)
    property :metre, :label => 'Metre', :comment =>
      %(A number of metres)
    property :name, :label => 'Name', :comment =>
      %(Name)
    property :note, :label => 'Note', :comment =>
      %(Note)
    property :origination, :label => 'Origination', :comment =>
      %(An agent responsible for the creation or accumulation of the
        archival resource.)
    property :other, :label => 'Other', :comment =>
      %(Other)
    property :otherFindingAids, :label => 'Other Finding Aids', :comment =>
      %(Other Finding Aids)
    property :page, :label => 'Page', :comment =>
      %(A number of pages)
    property :paper, :label => 'Paper', :comment =>
      %(A number of papers)
    property :physicalTechnicalRequirements, :label => 'Physical and Technical Requirements', :comment =>
      %(Physical and Technical Requirements)
    property :processing, :label => 'Processing', :comment =>
      %(Processing)
    property :providesAccessTo, :label => 'Provides Access To', :comment =>
      %(A resource to which the agent provides access.)
    property :relatedMaterial, :label => 'Related Material', :comment =>
      %(Related Material)
    property :scopecontent, :label => 'Scope and Content', :comment =>
      %(Scope and Content)
    property :surname, :label => 'Surname', :comment =>
      %(The surname of a person who is the focus of the concept)
    property :title, :label => 'Title', :comment =>
      %(The title of a person who is the focus of the concept)
    property :useRestrictions, :label => 'Use Restrictions', :comment =>
      %(Use Restrictions)
    property :volume, :label => 'Volume', :comment =>
      %(A number of volumes)

    # Other terms
  end
end
