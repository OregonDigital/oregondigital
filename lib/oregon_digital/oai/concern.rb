module OregonDigital::OAI::Concern
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end

  module ClassMethods
    def uri_fields
      @uri_fields = [:creator, :lcsubject, :type, :format, :rights, :location, :author, :editor, :photographer, :rangerDistrict, :set]
    end

    # Map Qualified Dublin Core (Terms) fields to Oregon Digital fields
    def map_oai_qdc
      { :title => [:title],
        :description => [:description],
        :identifier => [:identifier],
        :date => [:date],
        :created => [:created],
        :issued => [:issued],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :donor, :editor, :photographer],
        :subject => [:lcsubject, :subject],
        :rights => [:rights],
        :spatial => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress],
        :type => [:type],
#        :format => [:format],
        :language => [:language],
        :isPartOf => [:set]
      }
    end

    # Map Dublin Core (Elements) fields to Oregon Digital fields
    def map_oai_dc
      { :title => [:title],
        :description => [:description],
        :date => [:date],
        :identifier => [:identifier],
        :creator => [:creator],
        :contributor => [:arranger, :artist, :author, :cartographer, :collector, :composer, :contributor, :donor, :editor, :photographer],
        :subject => [:lcsubject, :subject],
        :coverage => [:location, :tgn, :waterBasin, :rangerDistrict, :streetAddress],
        :publisher => [:publisher],
        :type => [:type],
#        :format => [:format],
#        :source => [:source],
        :language => [:language],
        :relation => [:set],
        :rights => [:rights]
      }
    end
  end
end

