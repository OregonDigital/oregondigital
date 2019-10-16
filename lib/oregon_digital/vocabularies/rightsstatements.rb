require 'rdf'
module OregonDigital::Vocabularies
  class RIGHTSSTATEMENTS < ::RDF::StrictVocabulary("http://rightsstatements.org/vocab/")
    property :"CNE/1.0/", :label => 'COPYRIGHT NOT EVALUATED'
    property :"InC-EDU/1.0/", :label => 'IN COPYRIGHT - EDUCATIONAL USE PERMITTED'
    property :"InC-NC/1.0/", :label => 'IN COPYRIGHT - NON-COMMERCIAL USE PERMITTED'
    property :"InC-OW-EU/1.0/", :label => 'IN COPYRIGHT - EU ORPHAN WORK'
    property :"InC-RUU/1.0/", :label => 'IN COPYRIGHT - RIGHTS-HOLDER(S) UNLOCATABLE OR UNIDENTIFIABLE'
    property :"InC/1.0/", :label => 'IN COPYRIGHT'
    property :"NKC/1.0/", :label => 'NO KNOWN COPYRIGHT'
    property :"NoC-CR/1.0/", :label => 'NO COPYRIGHT - CONTRACTUAL RESTRICTIONS'
    property :"NoC-NC/1.0/", :label => 'NO COPYRIGHT - NON-COMMERCIAL USE ONLY'
    property :"NoC-OKLR/1.0/", :label => 'NO COPYRIGHT - OTHER KNOWN LEGAL RESTRICTIONS'
    property :"NoC-US/1.0/", :label => 'NO COPYRIGHT - UNITED STATES'
    property :"UND/1.0/", :label => 'COPYRIGHT UNDETERMINED'
  end
end
