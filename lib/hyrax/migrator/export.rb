# frozen_string_literal:true

module Hyrax::Migrator
  ##
  # To use during the export step in OD2 migration workflow
  # Example:
  #  e = Hyrax::Migrator::Export.new('/data1/batch/exports', 'test-bags', 'test-bags-pidlist.txt', true)
  #  e.export
  class Export
    def initialize(export_dir, export_name, pidlist, verbose = false)
      @export_dir = export_dir
      @export_name = export_name
      @datastreams_dir = File.join(export_dir, export_name)
      @pidlist = pidlist
      @verbose = verbose
      @keylist = keylist
      datetime_today = Time.zone.now.strftime('%Y-%m-%d-%H%M%S') # "2017-10-21-125903"
      @reporter = ExportReporter.new
      @logger = Logger.new(File.join(@export_dir, 'exportlogs',
                                     "export_#{export_name}_#{datetime_today}.log"))
    end

    def export
      puts "Exporting #{@export_name}." if @verbose
      Dir.mkdir(@export_dir) unless Dir.exist?(@export_dir)
      Dir.mkdir(@datastreams_dir) unless Dir.exist?(@datastreams_dir)
      export_datastreams
      make_bags
    rescue StandardError => e
      message = "Error #{e.message}:#{e.backtrace.join("\n")}"
      puts message if @verbose
      @logger.error(message)
    end

    def export_datastreams
      File.readlines(File.join(@export_dir, @pidlist)).each do |line|
        puts "Exporting datastreams for #{line}." if @verbose
        item = GenericAsset.find(line.strip)
        next unless item.present?

        add_content_to_keylist(item)
        export_metadata(item, line)
        export_workflow_metadata_profile(item, line)
        @reporter.update(item)
      end
      @reporter.log(@logger)
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

    def add_content_to_keylist(item)
      @keylist['content'] = asset_mimetype(item) unless item.datastreams['content'].blank?
    end

    def asset_mimetype(item)
      item.datastreams['content'].mimeType.split('/').last
    end

    def export_metadata(item, line)
      @keylist.each do |key, ext|
        next if item.datastreams[key].blank?

        filename = line.strip.gsub('oregondigital:', '') + '_' + key + '.' + ext
        write_file(filename, item.datastreams[key].content)
      end
    end

    def export_workflow_metadata_profile(item, line)
      profile = item.datastreams['workflowMetadata'].profile.to_yaml
      write_file(line.strip.gsub('oregondigital:', '') + '_workflowMetadata_profile.yml', profile)
    end

    def write_file(filename, content)
      f = File.open(File.join(@datastreams_dir, filename), 'wb')
      f.write(content)
      f.close
    end

    def make_bags
      puts "Bagging from #{@datastreams_dir}..." if @verbose
      bag_dir = @datastreams_dir + '_bags'
      Dir.mkdir bag_dir unless Dir.exist? bag_dir

      Dir.chdir(@datastreams_dir)
      Dir.glob('*.nt').each do |item|
        pid = get_short_pid(item)
        list = Dir.glob("*#{pid}*")
        make_bag(bag_dir, @datastreams_dir, list, pid)
        validate_list(list, pid) if @verbose
      end
      puts 'Completed bagging.' if @verbose
    end

    def make_bag(dir, source_dir, list, pid)
      bag = BagIt::Bag.new(File.join(dir, pid))

      list.each do |item|
        bag.add_file(item, File.join(source_dir, item))
      end
      bag.tagmanifest!
      bag.manifest!
    end

    def get_short_pid(filename)
      pid = /[a-z0-9]{9}/.match filename
      pid.to_s.try(:gsub, 'oregondigital-', '') unless pid.nil?
    end

    def validate_list(list, pid)
      valid = list.join.include? 'content'
      message = valid ? "bagged #{pid}" : "no content file included for #{pid}"
      puts message if @verbose
      @logger.info message if valid == false
    end
  end
end
