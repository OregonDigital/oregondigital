module OregonDigital
  module DateSorting
    extend ActiveSupport::Concern
    def to_solr(solr_doc={})
      solr_doc = super
      solr_doc = solr_doc.merge({"sort_date_desc_dtsi" => sort_date_desc, "sort_date_asc_dtsi" => sort_date_asc})
      solr_doc = solr_doc.merge({"date_decades_ssim" => decades})
      solr_doc
    end

    def decades
      return nil if decade_dates.empty?
      decade_dates.map(&:decade)
    rescue ArgumentError
    end

    def decade_dates
      dates = DateDecadeConverter.new(date).run
      dates ||= Array.wrap(DecadeDecorator.new(clean_datetime.year))
    end
    
    class DecadeDecorator
      attr_accessor :year
      def initialize(year)
        @year = year
      end

      def decade
        "#{first_year}-#{last_year}"
      end

      private

      def first_year
        year - year%10
      end

      def last_year
        year + 10 - (year+10)%10 - 1
      end
    end

    class DateDecadeConverter
      attr_accessor :date
      def initialize(date)
        @date = date
      end

      def run
        return unless valid_date_range?
        decades.times.map do |decade|
          DecadeDecorator.new(earliest_date + 10*decade)
        end
      end

      private

      def earliest_date
        @earliest_date ||= dates.first - dates.first%10
      end

      def valid_decade_size?
        decades <= 3
      end

      def valid_date_range?
        dates.first.to_s.length == 4 && dates.last.to_s.length == 4 && dates.length == 2
      end

      def dates
        @dates ||= date.to_s.split("-").map(&:to_i)
      end

      def decades
        if calculated_decades <= 3
          calculated_decades
        else
          0
        end
      end

      def calculated_decades
        (dates.last-dates.first)/10 + 1
      end

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
