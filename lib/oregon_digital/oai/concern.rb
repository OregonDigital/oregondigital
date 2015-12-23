module OregonDigital::OAI::Concern
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end

  module ClassMethods
    # Oregon Digital fields that store RDF URIs and labels need to be looked up for
    def uri_fields
      @uri_fields = [:creator, :lcsubject, :type, :format, :rights, :location, :author, :editor, :photographer, :rangerDistrict, :set,
                      :taxonClass, :arranger, :artist, :author, :collector, :composer, :illustrator, :interviewee, :interviewer, :lyricist, 
                      :photographer, :translator, :ethnographicTerm, :genus, :phylum, :militaryBranch, :stylePeriod, :commonNames, :language, 
                      :localCollectionName, :od_repository]
    end

    # Map Qualified Dublin Core (Terms) fields to Oregon Digital fields
    def map_oai_qdc
      { :title => [:title],
        :alternative => [:alternative],
        :description => [:description, :descriptionOfManifestation, :culturalContext, :stylePeriod, :awardDate],
        :abstract => [:abstract],
        :identifier => [:identifier, :accessionNumber, :itemLocator],
        :date => [:date, :viewDate],
        :created => [:created],
        :issued => [:issued],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :donor, :editor, :illustrator,
                          :interviewee, :interviewer, :lyricist, :patron, :photographer, :printMaker, :scribe, :transcriber, :translator],
        :subject => [:lcsubject, :subject, :taxonClass, :ethnographicTerm, :event, :family, :genus, :phylum, :militaryBranch, :sportsTeam,
                     :tribalClasses, :tribalTerms, :commonNames],
        :rights => [:rights, :useRestrictions, :accessRestrictions],
        :rightsHolder => [:rightsHolder],
        :license => [:license],
        :publisher => [:publisher, :od_repository],
        :provenance => [:provenance],
        :spatial => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress, :geobox, :latitude, :longitude],
        :type => [:type],
#        :format => [:format],
#        :source => [:source],
        :language => [:language],
        :isPartOf => [:set, :containedInJournal, :localCollectionName, :isPartOf, :largerWork],
        :tableOfContents => [:tableOfContents],
        :temporal => [:temporal],
        :bibliographicCitation => [:citation],
        :relation => [:relation, :artSeries],
        :isReferencedBy => [:findingAid],
        :hasPart => [:hasPart],
        :hasVersion => [:hasVersion],
        :isVersionOf => [:isVersionOf],
        :extent => [:extent, :physicalExtent, :measurements]
      }
    end

    # Map Dublin Core (Elements) fields to Oregon Digital fields
    def map_oai_dc
      { :title => [:title, :alternative],
        :description => [:description, :abstract, :descriptionOfManifestation, :culturalContext, :stylePeriod, :awardDate],
        :date => [:date, :created, :viewDate],
        :identifier => [:identifier, :accessionNumber, :itemLocator],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :donor, :editor, :illustrator,
                          :interviewee, :interviewer, :lyricist, :patron, :photographer, :printMaker, :scribe, :transcriber, :translator],
        :subject => [:lcsubject, :subject, :taxonClass, :ethnographicTerm, :event, :family, :genus, :phylum, :militaryBranch, :sportsTeam,
                     :tribalClasses, :tribalTerms, :commonNames],
        :coverage => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress, :temporal, :geobox, :latitude, :longitude],
        :publisher => [:publisher, :od_repository],
        :type => [:type],
#        :format => [:format],
#        :source => [:source],
        :language => [:language],
        :relation => [:relation, :set, :localCollectionName, :artSeries, :findingAid],
        :rights => [:rights, :rightsHolder, :license, :useRestrictions, :accessRestrictions]
      }
    end
  end
end

