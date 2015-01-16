module OregonDigital
  module DateSorting
    extend ActiveSupport::Concern
    def to_solr(solr_doc={})
      solr_doc = super
      solr_doc = solr_doc.merge({"sort_date_desc_dtsi" => sort_date_desc, "sort_date_asc_dtsi" => sort_date_asc})
      solr_doc
    end

    def sort_date_desc
      begin
        clean_datetime.to_time.utc.iso8601
      rescue ArgumentError
        DateTime.strptime("-9999","%Y").to_time.utc.iso8601 # Default for bad dates so they're put at the end
      end
    end

    def sort_date_asc
      begin
        clean_datetime.to_time.utc.iso8601
      rescue ArgumentError
        DateTime.strptime("9999","%Y").to_time.utc.iso8601 # Default for bad dates so they're put at the end
      end
    end

    def clean_datetime
      if date =~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}$/ # YYYY-MM-DD
        DateTime.strptime(date, "%Y-%m-%d")
      elsif date =~ /^[0-9]{4}-[0-9]{2}$/ # YYYY-MM
        DateTime.strptime(date, "%Y-%m")
      elsif date =~ /^[0-9]{4}/
        DateTime.strptime(date.split("-").first, "%Y")
      else
        raise ArgumentError
      end
    end
  end
end
