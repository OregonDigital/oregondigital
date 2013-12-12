module OregonDigital
  module Vocabularies
    ##
    # Darwin Core
    #
    # @see http://rs.tdwg.org/dwc/terms/
    class DWC < ::RDF::Vocabulary("http://rs.tdwg.org/dwc/terms/")
      property :class
      property :order
      property :family
      property :genus
      property :phylum
      property :higherClassification
      property :vernacularName
      property :identificationVerificationStatus
    end
  end
end