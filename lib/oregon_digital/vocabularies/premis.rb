# This file generated automatically using vocab-fetch from http://www.loc.gov/premis/rdf/v1.nt
require 'rdf'
module OregonDigital::Vocabularies
  class PREMIS < ::RDF::StrictVocabulary("http://www.loc.gov/premis/rdf/v1#")

    # Class definitions
    property :Agent, :comment =>
      %(The Agent entity aggregates information about attributes or
        characteristics of agents \(persons, organizations, or
        software\) associated with rights management and preservation
        events in the life of a data object. Agent information serves
        to identify an agent unambiguously from all other Agent
        entities.)
    property :ApplicableDates
    property :Bitstream
    property :ContentLocation
    property :CopyrightInformation
    property :CreatingApplication
    property :Dependency
    property :Environment
    property :Event, :comment =>
      %(The Event entity aggregates information about an action that
        involves one or more Object entities. Metadata about an Event
        would normally be recorded and stored separately from the
        digital object. Whether or not a preservation repository
        records an Event depends upon the importance of the event.
        Actions that modify objects should always be recorded. Other
        actions such as copying an object for backup purposes may be
        recorded in system logs or an audit trail but not necessarily
        in an Event entity. Mandatory semantic units are:
        eventIdentifier, eventType, and eventDateTime.)
    property :EventOutcomeDetail
    property :EventOutcomeInformation
    property :File
    property :Fixity
    property :Format
    property :FormatDesignation
    property :FormatRegistry
    property :Hardware
    property :Identifier, :comment =>
      %(This class is used in PREMIS OWL to describe identifiers if
        the identifiers are not http URIs.)
    property :Inhibitors
    property :IntellectualEntity, :comment =>
      %(Intellectual entities are described via Descriptive metadata
        models. These are very domain-specific and are out of scope
        for PREMIS. Examples: Dublin Core, Mets, MARC)
    property :LicenseInformation
    property :Object, :comment =>
      %(The object class aggregates information about a digital object
        held by a preservation repository and describes those
        characteristics relevant to preservation management. The only
        mandatory property is objectIdentifier. The object class has
        three subclasses: Representation, File, and Bitstream.)
    property :ObjectCharacteristics
    property :PremisEntity
    property :PreservationLevel
    property :RelatedObjectIdentification
    property :Representation
    property :RightsDocumentation
    property :RightsGranted
    property :RightsStatement, :comment =>
      %(Extensions: In OWL one can define its own subclasses to the
        the RightsStatement class to denote OtherRightsInformation of
        the PREMIS data dictionary.)
    property :Signature
    property :SignificantProperties
    property :Software
    property :StatuteInformation
    property :Storage
    property :TermOfGrant
    property :TermOfRestriction

    # Property definitions
    property :hasAgentName, :comment =>
      %(Examples: Erik Owens, Pc)
    property :hasAgentNote
    property :hasCompositionLevel, :comment =>
      %(Examples: 0, 1, 2)
    property :hasCompositionLevel, :comment =>
      %(Data Constraints: Non-negative integers.)
    property :hasContentLocationValue, :comment =>
      %(Examples:
        http://wwasearch.loc.gov/107th/200212107035/http://house.gov/langevin/
        \(file\), c:\apache2\htdocs\index.html \(file\), 64 [offset
        from start of file c:\apache2\htdocs\image\logo.gif]
        \(bitstream\))
    property :hasCopyrightJurisdiction, :comment =>
      %(Examples: us, de, be)
    property :hasCopyrightJurisdiction, :comment =>
      %(Data Constraint: Values should be taken from ISO 3166.)
    property :hasCopyrightStatusDeterminationDate, :comment =>
      %(Example: 2001-10-26T19:32:52+00:00)
    property :hasCopyrightStatusDeterminationDate, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasCreatingApplicationName, :comment =>
      %(Example: MSWord)
    property :hasCreatingApplicationVersion, :comment =>
      %(Example: 2000)
    property :hasDateCreatedByApplication, :comment =>
      %(Example: 2001-10-26T19:32:52+00:00)
    property :hasDateCreatedByApplication, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasDependencyName, :comment =>
      %(Example: Additional Element Set for Language Corpora)
    property :hasEndDate, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasEnvironmentNote, :comment =>
      %(Example: This environment assumes that the PDF will be stored
        locally and used with a standalone PDF reader.)
    property :hasEventDateTime, :comment =>
      %(Example: 2001-10-26T19:32:52+00:00)
    property :hasEventDateTime, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasEventDetail, :comment =>
      %(Examples: Object permanently withdrawn by request of Caroline
        Hunt, Program="MIGJP2JP2K"; version="2.2")
    property :hasEventOutcome, :comment =>
      %(Data Constraint: Value should be taken from a controlled
        vocabulary.)
    property :hasEventOutcome, :comment =>
      %(Examples: 00 [a code meaning "action successfully completed"],
        CV-01 [a code meaning "checksum validated"])
    property :hasEventOutcomeDetailNote, :comment =>
      %(Examples: LZW compressed file, Non-standard tags found in
        header)
    property :hasFormatName, :comment =>
      %(Data Constraint: Value should be taken from a controlled
        vocabulary.)
    property :hasFormatName, :comment =>
      %(Examples: Text/sgml, image/tiff/geotiff, Adobe PDF, DES, PGP,
        base64, unknown, LaTex)
    property :hasFormatNote, :comment =>
      %(Examples: tentative identification, disjunction, multiple
        format identifications found)
    property :hasFormatRegistryKey, :comment =>
      %(Examples: info:gdfr/fred/f/tiff, TIFF/6.0)
    property :hasFormatRegistryName, :comment =>
      %(Examples: PRONOM, www.nationalarchives.gov.uk/pronom,
        Representation Information Registry Repository, FRED: A format
        registry demonstration, release 0.07)
    property :hasFormatVersion, :comment =>
      %(Examples: 6.0, 2003)
    property :hasHardwareName, :comment =>
      %(Examples: Intel Pentium III, 1 GB DRAM, Windows XPcompatible
        joystick)
    property :hasHardwareOtherInformation, :comment =>
      %(Examples: 32MB minimum, Required RAM for Apache is unknown)
    property :hasIdentifierType, :comment =>
      %(Data Constraint: Value should be taken from controlled
        vocabulary.)
    property :hasIdentifierType, :comment =>
      %(Examples: DLC, DRS, hdl:4263537)
    property :hasIdentifierValue, :comment =>
      %(Examples: 0000000312 \(Representation\), IU2440 \(File\),
        WAC1943.56 \(File\),
        http://nrs.harvard.edu/urn-3:FHCL.Loeb:sal \(File\), IU2440-1
        \(Bitstream\))
    property :hasIdentifierValue, :comment =>
      %(Defnition: The value of the Identifier.)
    property :hasInhibitorKey, :comment =>
      %(Example: [DES decryption key])
    property :hasLicenseTerms
    property :hasMessageDigest, :comment =>
      %(Example:
        7c9b35da4f2ebd436f1cf88e5a39b3a257edf4a22be3c955ac49da2e2107b67a1924419563)
    property :hasMessageDigestOriginator, :comment =>
      %(Examples: DRS, A0000978)
    property :hasOriginalName, :comment =>
      %(Example: N419.pdf)
    property :hasPreservationLevelDateAssigned, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasPreservationLevelDateAssigned, :comment =>
      %(Examples: 2001-10-26T19:32:52+00:00)
    property :hasPreservationLevelRationale, :comment =>
      %(Examples: user pays, legislation, defective file, bit-level
        preservation only available for this format)
    property :hasPreservationLevelValue, :comment =>
      %(Examples: bit-level, full, fully supported with future
        migrations \(File\), 0)
    property :hasPreservationLevelValue, :comment =>
      %(Data Constraint: Value should be taken from a controlled
        vocabulary.)
    property :hasRelatedObjectSequence
    property :hasRestriction, :comment =>
      %(Examples: No more than three, Allowed only after one year of
        archival retention has elapsed, Rightsholder must be notified
        after completion of act)
    property :hasRightsGrantedNote
    property :hasRightsStatementNote, :comment =>
      %(Examples: Copyright expiration expected in 2010 unless
        renewed. License is embedded in XMP block in file header.)
    property :hasSignatureProperties
    property :hasSignatureValidationRules
    property :hasSignatureValue, :comment =>
      %(Example:
        juS5RhJ884qoFR8flVXd/rbrSDVGn40CapgB7qeQiT+rr0NekEQ6BHhUA8dT3+BCTBUQI0dBjlml9lwzENXvS83zRECjzXbMRTUtVZiPZG2pqKPnL2YU3A9645UCjTXU+jgFumv7k78hieAGDzNci+PQ9KRmm//icT7JaYztgt4=)
    property :hasSignificantPropertiesType, :comment =>
      %(Examples: content, structure, behavior, page count, page
        width, typeface, hyperlinks \(representation\), image count
        \(representation\), color space [for an embedded image]
        \(bitstream\))
    property :hasSignificantPropertiesValue, :comment =>
      %(Examples: [For a Web page containing animation that is not
        considered essential] Content only, [For detail associated
        with a significantPropertiesType of "behavior"] Hyperlinks
        traversable, [For a Word document with embedded links that are
        not considered essential] Content only, [For detail associated
        with significantPropertiesType of "behavior"] Editable, [For
        detail associated with a significantPropertiesType of "page
        width"] 210 mm, [For a PDF with an embedded graph, where the
        lines\' color determines the lines\' meaning] Color, [For
        detail associated with a significantPropertiesType of
        "appearance"] Color)
    property :hasSize, :comment =>
      %(Example: 2038937)
    property :hasSoftwareDependency, :comment =>
      %(Example: GNU gcc >=2.7.2)
    property :hasSoftwareName, :comment =>
      %(Examples: Adobe Photoshop, Adobe Acrobat Reader)
    property :hasSoftwareOtherInformation, :comment =>
      %(Example: Install Acroread \(Adobe Acrobat\) first; copy
        nppdf.so \(the plug-in\) to your Mozilla plug-ins directory,
        and make sure a copy of \(or symlink to\) Acroread is in your
        PATH.)
    property :hasSoftwareVersion, :comment =>
      %(Examples: >=2.2.0, 6.0, 2003)
    property :hasStartDate, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasStatuteInformationDeterminationDate, :comment =>
      %(Data Constraint: To aid machine processing, value should use a
        structured form: xsd:dateTime)
    property :hasStatuteInformationDeterminationDate, :comment =>
      %(Example: 2001-10-26T19:32:52+00:00)
    property :hasStatuteJurisdiction, :comment =>
      %(Examples: us, de, be)
    property :hasStatuteJurisdiction, :comment =>
      %(Data Constraint: Values should be taken from a controlled
        vocabulary.)
    property :hasAct, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasAct, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/actionsGranted)
    property :hasAgent
    property :hasAgentType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/agentType)
    property :hasAgentType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasApplicableDates
    property :hasContentLocation
    property :hasContentLocationType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasContentLocationType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/contentLocationType)
    property :hasCopyrightStatus, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasCopyrightStatus, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/copyrightStatus)
    property :hasCreatingApplication
    property :hasDependency
    property :hasEnvironment
    property :hasEnvironmentCharacteristic, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasEnvironmentCharacteristic, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/environmentCharacteristic)
    property :hasEnvironmentPurpose, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/environmentPurpose)
    property :hasEnvironmentPurpose, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasEvent
    property :hasEventOutcomeDetail
    property :hasEventOutcomeInformation
    property :hasEventRelatedAgent, :comment =>
      %(This propety links a Event instance to an Agent instance. Via
        this property a distinction can be made in the linkingAgent
        properties based on the domain.)
    property :hasEventRelatedAgent, :comment =>
      %(Extensions: One can extend this property to use more fine
        grained properties by defining the fine grained properties as
        subproperties of this property.)
    property :hasEventRelatedObject, :comment =>
      %(Extensions: One can extend this property to use more fine
        grained properties by defining the fine grained properties as
        subproperties of this property.)
    property :hasEventType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/eventType)
    property :hasEventType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasFixity
    property :hasFormat
    property :hasFormatDesignation
    property :hasFormatRegistry
    property :hasFormatRegistryRole, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasFormatRegistryRole, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/formatRegistryRole)
    property :hasHardware
    property :hasHardwareType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasHardwareType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/hardwareType)
    property :hasIdentifier
    property :hasInhibitorTarget, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/inhibitorTarget)
    property :hasInhibitorTarget, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasInhibitorType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/inhibitorType)
    property :hasInhibitorType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasInhibitors
    property :hasIntellectualEntity
    property :hasKeyInformation
    property :hasMessageDigestAlgorithm, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/cryptographicHashFunctions)
    property :hasMessageDigestAlgorithm, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasObject, :comment =>
      %(Extensions: One can extend this property to use more fine
        grained properties by defining the fine grained properties as
        subproperties of this property.)
    property :hasObjectCharacteristics
    property :hasPreservationLevel
    property :hasPreservationLevelRole, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasPreservationLevelRole, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/preservationLevelRole)
    property :hasRelatedObject
    property :hasRelatedStatuteInformation
    property :hasRelationship, :comment =>
      %(The LOC will provide a SKOS vocabulary, where the concepts can
        also be used as object properties at http://id.loc.gov/. These
        relationships will capture the relationship type and subtype.
        One can define its own relationships, but for interoperability
        reasons, these should be linked to or made a subproperty of
        the properties of the LOC vocabulary.)
    property :hasRelationship, :comment =>
      %(Extensions: One can extend this property to use more fine
        grained properties by defining the fine grained properties as
        subproperties of this property.)
    property :hasRightsDocumentation
    property :hasRightsDocumentationRole
    property :hasRightsGranted
    property :hasRightsRelatedAgent, :comment =>
      %(Extensions: One can extend this property to use more fine
        grained properties by defining the fine grained properties as
        subproperties of this property.)
    property :hasRightsRelatedAgent, :comment =>
      %(This propety links a RightsStatement instance to an Agent
        instance. Via this property a distinction can be made in the
        linkingAgent properties based on the domain.)
    property :hasRightsStatement
    property :hasSignature
    property :hasSignatureEncoding, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/signatureEncoding)
    property :hasSignatureEncoding, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasSignatureMethod, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasSignatureMethod, :comment =>
      %(Data Constraint: Values are taken from a SKOS vocabulary)
    property :hasSignificantProperties
    property :hasSoftware
    property :hasSoftwareType, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasSoftwareType, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/softwareType)
    property :hasStorage
    property :hasStorageMedium, :comment =>
      %(Data Constraint: Values are taken from the SKOS vocabulary:
        http://id.loc.gov/vocabulary/preservation/storageMedium)
    property :hasStorageMedium, :comment =>
      %(Extensions: One can use its own SKOS vocabulary to use for
        this property. The precondition to do this, is to link your
        SKOS concepts to the SKOS concepts of the id.loc.gov
        vocabulary.)
    property :hasTermOfGrant
    property :hasTermOfRestriction
    property :hasSigner
  end
end
