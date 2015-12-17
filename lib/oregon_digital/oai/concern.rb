module OregonDigital::OAI::Concern
  extend ActiveSupport::Concern
  included do
    def parsed_modified_date
      Time.parse(modified_date).utc
    end
  end

  module ClassMethods
    def string_fields
      @string_fields = [:title, :description, :date, :identifier]
    end
    def uri_fields
      @uri_fields = [:creator, :lcsubject, :type, :format, :rights, :location, :author, :editor, :photographer, :rangerDistrict, :set]
    end

    def mapped_fields
      @mapped_fields = {#:lcsubject => "subject",
#                        :location => "coverage",
#                        :photographer => "creator2"
      }
    end

    # Map Oregon Digital fields to Qualified Dublin Core fields
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
  end
end

