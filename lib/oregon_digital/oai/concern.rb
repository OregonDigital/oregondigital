module OregonDigital::OAI::Concern
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end

  module ClassMethods
    # Oregon Digital fields that store RDF URIs and labels need to be looked up for
    # do not include fields here that have a method in the decorator, eg rights, any field using geonames, primarySet
    def uri_fields
      @uri_fields = [:creator, :lcsubject, :type, :author, :editor, :photographer, :phylum, :taxonClass, :order, :family,
                     :genus, :species, :commonNames, :arranger, :artist, :author, :collector, :composer, :contributor, :illustrator,
                     :interviewee, :interviewer, :lyricist, :photographer, :translator, :owner, :designer, :ethnographicTerm, :militaryBranch, :stylePeriod,
                     :language, :localCollectionName, :od_repository, :recipient, :set, :publisher, :landscapeArchitect]
    end

    # Map Qualified Dublin Core (Terms) fields to Oregon Digital fields
    def map_oai_qdc
      { :title => [:title],
        :alternative => [:alternative],
        :description => [:description, :descriptionOfManifestation, :culturalContext, :stylePeriod, :designerLabel, :motif],
        :abstract => [:abstract],
        :identifier => [:accessURL],
        :date => [:date, :viewDate, :earliestDate, :created, :awardDate, :issued],
        :created => [:created],
        :issued => [:issued],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :editor, :illustrator,
                          :interviewee, :interviewer, :lyricist, :patron, :photographer, :printMaker, :scribe, :transcriber, :translator, 
                          :dedicatee, :recipient, :owner, :designer, :landscapeArchitect],
        :subject => [:lcsubject, :subject, :phylum, :taxonClass, :order, :family, :genus, :species, :commonNames, :ethnographicTerm, :event, :militaryBranch, :sportsTeam,
                     :tribalClasses, :tribalTerms, :award, :legalName],
        :rights => [:rights, :useRestrictions, :accessRestrictions],
        :rightsHolder => [:rightsHolder],
        :license => [:license],
        :publisher => [:publisher, :od_repository],
        :provenance => [:provenance],
        :spatial => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress, :geobox, :latitude, :longitude],
        :type => [:type],
        :language => [:language],
        :isPartOf => [:set, :containedInJournal, :localCollectionName, :isPartOf, :largerWork],
        :tableOfContents => [:tableOfContents],
        :temporal => [:temporal],
        :bibliographicCitation => [:citation],
        :relation => [:relation, :artSeries],
        :isReferencedBy => [:findingAid],
        :hasPart => [:hasPart],
        :isVersionOf => [:isVersionOf],
        :extent => [:extent, :physicalExtent, :measurements],
        :format => [:format]
      }
    end

    # Map Dublin Core (Elements) fields to Oregon Digital fields
    def map_oai_dc
      { :title => [:title, :alternative],
        :description => [:description, :abstract, :descriptionOfManifestation, :culturalContext, :stylePeriod, :awardDate],
        :date => [:date, :created, :viewDate, :earliestDate],
        :identifier => [:accessURL],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :editor, :illustrator,
                          :interviewee, :interviewer, :lyricist, :patron, :photographer, :printMaker, :scribe, :transcriber, :translator,
                          :dedicatee, :recipient, :owner, :designer, :landscapeArchitect],
        :subject => [:lcsubject, :subject, :phylum, :taxonClass, :order, :family, :genus, :species, :commonNames, :ethnographicTerm, :event, :militaryBranch, :sportsTeam,
                     :tribalClasses, :tribalTerms, :award, :legalName],
        :coverage => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress, :temporal, :geobox, :latitude, :longitude],
        :publisher => [:publisher, :od_repository],
        :type => [:type],
        :language => [:language],
        :relation => [:relation, :set, :localCollectionName, :artSeries, :findingAid],
        :rights => [:rights, :rightsHolder, :license, :useRestrictions, :accessRestrictions],
        :format => [:format]
      }
    end


    # For each Dublin Core field, oai_qdc_map returns properties, this gets called to grab values
    def value_for(field, record, map)
      method = map[field] ? map[field] : field

      val = []

      method.each do |fld|
        if record.respond_to?(fld) && !record.send(fld).nil?
          val << record.send(fld) unless record.send(fld).empty?
        elsif record.descMetadata.respond_to?(fld) && !record.descMetadata.send(fld).nil?
          val << record.descMetadata.send(fld) unless record.descMetadata.send(fld).empty?
        end
      end

      if val.is_a?(String) && !val.nil?
        return val
      elsif val.is_a?(Array) && !val.empty?
        return val.join('; ')
      else
        return nil
      end
    end


    # Copied from ruby-oai gem: ruby-oai/lib/oai/provider/metadata_format.rb
    # Changed to not write out fields if values are nil
    def encode(model, record)
      if record.respond_to?("to_#{prefix}")
        record.send("to_#{prefix}")
      else
        xml = Builder::XmlMarkup.new
        map = model.respond_to?("map_#{prefix}") ? model.send("map_#{prefix}") : {}
          xml.tag!("#{prefix}:#{element_namespace}", header_specification) do
            fields.each do |field|
              values = value_for(field, record, map)
              next if values.nil?
              if values.respond_to?(:each)
                values.each do |value|
                  xml.tag! "#{element_namespace}:#{field}", value
                end
              else
                xml.tag! "#{element_namespace}:#{field}", values
              end
            end
          end
        xml.target!
      end
    end
  end
end

