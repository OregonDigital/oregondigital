# frozen_string_literal:true

module Hyrax::Migrator
  ##
  # To use during the export step in OD2 migration
  class Export
    def initialize(export_dir, export_name, pidlist, verbose = false)
      @export_dir = export_dir
      @export_name = export_name
      @datastreams_dir = File.join(export_dir, export_name)
      @pidlist = pidlist
      @verbose = verbose
      @keylist = keylist
      datetime_today = Time.zone.now.strftime('%Y-%m-%d-%H%M%S') # "2017-10-21-125903"
      report_filename = File.join(export_dir, "report_#{export_name}_#{datetime_today}.txt")
      @report = File.open(report_filename, 'w')
      @errors = []
    end

    def export
      begin
        @errors << "Exporting #{@export_name}"
        Dir.mkdir(@export_dir) unless Dir.exist?(@export_dir)
        Dir.mkdir(@datastreams_dir) unless Dir.exist?(@datastreams_dir)
        export_datastreams
        make_bags
      rescue StandardError => e
        @errors << "Error #{e.message}:#{e.backtrace.join("\n")}"
      end
      write_errors
      @report.close
    end

    def export_datastreams
      File.readlines(File.join(@export_dir, @pidlist)).each do |line|
        puts "exporting content for #{line}" if @verbose
        item = GenericAsset.find(line.strip)
        next unless item.present?

        add_content_to_keylist(item)
        export_data(item, item.datastreams[key].content, line)
      end
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

    def export_data(item, content, line)
      @keylist.each do |key, ext|
        next if item.datastreams[key].blank?

        cleanpid = line.strip.gsub('oregondigital:', '')
        f = File.open(File.join(@export_dir, cleanpid + '_' + key + '.' + ext), 'wb')
        f.write(content)
        f.close
      end
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
        if validate_list(list)
          puts "bagged #{pid}"
        else
          puts "no content file included for #{pid}"
        end
      end
      puts 'Completed bagging.'
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

    def validate_list(list)
      list.join.include? 'content'
    end

    def write_errors
      @errors.each do |e|
        @report.puts e
      end
    end
  end
end
