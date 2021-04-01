# frozen_string_literal:true

module Hyrax::Migrator
  ##
  # To use during the export step in OD2 migration workflow
  # Example for a batch named named mycoll-batch1
  #  e = Hyrax::Migrator::Export.new('/data1/batch/exports', 'mycoll-batch1', 'mycoll-batch1-pidlist.txt', true)
  #  e.export

  class Export
    include ChecksumsProfiler
    include MetadataProfiler
    def initialize(export_dir, export_name, pidlist, verbose = false)
      @export_dir = export_dir
      @export_name = export_name
      @bags_dir = File.join(export_dir, export_name)
      @pidlist = pidlist
      @verbose = verbose
      datetime_today = Time.zone.now.strftime('%Y-%m-%d-%H%M%S') # "2017-10-21-125903"
      @logger = Logger.new(File.join(@export_dir, 'exportlogs',
                                     "export_#{export_name}_#{datetime_today}.log"))
      Dir.mkdir(@bags_dir) unless Dir.exist?(@bags_dir)
    end

    ## Use when all datastreams need to be exported
    def export_all
      File.foreach(File.join(@export_dir, @pidlist)) do |line|
        begin
          short_pid = strip_pid(line.strip)
          puts "Exporting datastreams for #{short_pid}." if @verbose
          bag = BagIt::Bag.new(File.join(@bags_dir, short_pid))
          item = GenericAsset.find(line.strip)
          export_profile(item,  short_pid)
          export_content(item, short_pid)
          export_metadata(item, short_pid)
          export_workflow_metadata_profile(item, short_pid)
          bag_finisher(bag)
        rescue StandardError => e
          message = "Error #{e.message}:#{e.backtrace.join("\n")}"
          puts message if @verbose
          @logger.error(message)
        end
      end
    end

    ## Use when metadata has changed
    def export_metadata_only
      File.foreach(File.join(@export_dir, @pidlist)) do |line|
        begin
          short_pid = strip_pid(line.strip)
          item = GenericAsset.find(line.strip)
          bag = BagIt::Bag.new(File.join(@bags_dir, short_pid))
          export_profile(item, short_pid)
          export_metadata(item, short_pid)
          export_workflow_metadata_profile(item, short_pid)
          bag_finisher(bag)
        rescue StandardError => e
          message = "Error #{e.message}:#{e.backtrace.join("\n")}"
          puts message if @verbose
          @logger.error(message)
        end
      end
    end

    def export_content_only
      File.foreach(File.join(@export_dir, @pidlist)) do |line|
        begin
          short_pid = strip_pid(line.strip)
          puts "Exporting datastreams for #{short_pid}." if @verbose
          bag = BagIt::Bag.new(File.join(@bags_dir, short_pid))
          item = GenericAsset.find(line.strip)
          export_content(item, short_pid)
          bag_finisher(bag)
        rescue StandardError => e
          message = "Error #{e.message}:#{e.backtrace.join("\n")}"
          puts message if @verbose
          @logger.error(message)
        end
      end
    end

    def export_profile(item, short_pid)
      create_profile(data_dir(short_pid), item, @export_dir)
    end

    def bag_finisher(bag)
      bag.write_bag_info
      bag.tagmanifest!
      bag.manifest!
    end

    def export_content(item, short_pid)
      mimetype = asset_mimetype(item)
      return if mimetype == 'xml' && !od_content_is_empty(item)

      write_file(short_pid, "#{short_pid}_content.#{mimetype}", item.datastreams['content'].content)
      print_checksums(item.datastreams['content'].content, data_dir(short_pid), short_pid)
    rescue NoContentFileError => e
      return if !od_content_is_empty(item)

      @logger.error(e.message)
    end

    def od_content_is_empty(item)
      item.descMetadata.graph.query(:predicate => RDF::URI('http://opaquenamespace.org/ns/contents')).empty?
    end

    def asset_mimetype(item)
      item.datastreams['content'].mimeType.split('/').last
    rescue NoMethodError
      raise NoContentFileError
    end

    def export_metadata(item, short_pid)
      keylist.each do |key, ext|
        next if item.datastreams[key].blank?

        filename = "#{short_pid}_#{key}.#{ext}"
        write_file(short_pid, filename, item.datastreams[key].content)
      end
    end

    def export_workflow_metadata_profile(item, short_pid)
      profile = item.datastreams['workflowMetadata'].profile.to_yaml
      write_file(short_pid, "#{short_pid}_workflowMetadata_profile.yml", profile)
    end

    def strip_pid(pid)
      pid.gsub("oregondigital:", "")
    end

    def data_dir(short_pid)
      File.join(@bags_dir, short_pid + "/data")
    end

    def write_file(short_pid, filename, content)
      f = File.open(File.join(data_dir(short_pid), filename), 'wb')
      f.write(content)
      f.close
    end

    def keylist
      {
        'DC' => 'xml',
        'RELS-EXT' => 'xml',
        'rightsMetadata' => 'xml',
        'workflowMetadata' => 'yml',
        'descMetadata' => 'nt',
        'leafMetadata' => 'yml'
      }
    end

    class NoContentFileError < StandardError
    end
  end
end
