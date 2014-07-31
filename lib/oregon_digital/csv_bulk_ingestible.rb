require 'filemagic'

module OregonDigital
  module CsvBulkIngestible
    def ingest_from_csv(directory, review=false)
      saved_assets = []
      assets_from_csv(directory, true).each do |asset|
        begin 
          asset.review if review
          asset.save
          saved_assets << asset
        rescue Exception => e
          saved_assets.each { |saved| saved.delete }
          raise e
        end
      end
    end

    def assets_from_csv(directory, ingest=false)
      file = find_csv(directory)
      assets = []
      CSV.foreach(file, :headers => true, :header_converters => :symbol) do |row|
        ingest_column = row.delete(:ingest_filename)
        asset = asset_from_row(row)
        add_file_to_asset(File.join(directory, ingest_column[1]), asset) if ingest and ingest_column
        assets << asset
      end
      raise CsvBatchError.new(@field_errors, @value_errors, @file_errors) if csv_errors_exist?
      assets
    end

    private
      def csv_errors_exist?
        not (@field_errors.blank? and @value_errors.blank? and @file_errors.blank?)
      end
    
      def find_csv(dir)
        files = Dir.glob(File.join(dir, '*.csv'))
        raise "No CSV metadata file found." if files.count < 1
        raise "More than one CSV metadata file present." unless files.count == 1
        files.first
      end
      
      def asset_from_row(row, klass=self)
        asset = klass.new
        asset_properties = asset.descMetadata.singleton_class.properties
        row.each do |field, values|
          next if values.nil?
          field = field.to_s.camelize(:lower)
          unless asset_properties.keys.include?(field)
            @field_errors ||= []
            @field_errors << field
            next
          end
          values = values.split('|').map(&:strip).select { |v| not v.empty? }
          values.map! { |v| process_uri_value(v, asset_properties[field].
            class_name) } unless asset_properties[field].class_name.nil?
          begin
            asset.descMetadata.send("#{field}=".to_sym, values.compact)
          rescue Exception => e
            @value_errors ||= []
            @value_errors << [values, e.message]
          end
        end
        asset
      end

      def process_uri_value(uri, klass)
        begin
          if klass < ActiveFedora::Base 
            obj = klass.find(:pid => uri).first
            obj ||= klass.find(:pid => OregonDigital::IdService.namespaceize(uri)).first
            obj ||= klass.find(:pid => uri.split('/').last).first
            return obj unless obj.nil?
            raise "no #{klass} found with pid '#{uri}'"
          end
          return klass.new(uri)
        rescue Exception => e
          @value_errors ||= []
          @value_errors << [uri, e.message]
          nil
        end
      end

      def add_file_to_asset(file, asset)
        begin
          asset.content.content = IO.binread(file)
          asset.content.mimeType = mime_from_file(file)
        rescue Errno::ENOENT => e
          @file_errors ||= []
          @file_errors << File.basename(file)
        end
      end

      def mime_from_file(file)
        FileMagic.new(FileMagic::MAGIC_MIME).file(file).split(';')[0]
      end

    public
      
    class CsvBatchError < Exception
      attr_reader :field_errors, :value_errors, :file_errors

      def initialize(fields, values, files)
        @field_errors = fields.to_a
        @value_errors = values.to_a
        @file_errors = files.to_a
      end
    end
    
  end
end
