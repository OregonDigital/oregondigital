# frozen_string_literal: true

require 'bagit'

# Usage:
#
# task export_datastreams
# args
#   input_tsv: full path to the tsv file
#   batch: name of a batch or group of assets (or collections)
#
# example:
#
# RAILS_ENV=production bundle exec rake export_datastreams input_tsv="/data1/batch/exports/od2_seed_data_pids_Baseball_jpegs.tsv"
#
desc 'Export datastreams given a vts file'
task :export_datastreams => :environment do |t, args|
  path_to_tsv_file = ENV['input_tsv']
  path_to_export_dir = "/data1/batch/exports/"
  keylist = { "DC" => "xml", "RELS-EXT" => "xml", "rightsMetadata" => "xml", "workflowMetadata" => "yml", "descMetadata" => "nt", "leafMetadata" => "yml"}
  File.readlines(path_to_tsv_file).each do |line|
    line_cols = line.split("\t")
    item = GenericAsset.find(line_cols[0].strip)
    target_path = File.join(path_to_export_dir, line_cols[1].strip)
    Dir.mkdir(target_path) unless Dir.exists?(target_path)
    if !item.nil?
      keylist["content"] = item.datastreams["content"].mimeType.split("/").last unless item.datastreams["content"].blank?
      cleanpid = line_cols[0].strip.gsub(":", "-")
      onlypid = cleanpid.strip.gsub("oregondigital-","")
      puts "exporting #{onlypid}"
      keylist.each do |key, ext|
        next if item.datastreams[key].blank?
        f = File.open( File.join(target_path, onlypid + "_" + key + "." + ext), 'wb')
        f.write(item.datastreams[key].content)
        f.close
      end
    end
  end
  puts "export_datastreams done"
end

# Usage:
#
# task make_bags
# args
#   batch: name of a batch or group of assets (or collections)
#
# example:
#
# RAILS_ENV=production bundle exec rake make_bags batch="Baseball_jpegs"
#
desc 'Make bags given re-exported datastreams'
task :make_bags => :environment do |t, args|
  batch = ENV['batch']
  bag_dir = "/data1/batch/exports/#{batch}_datastreams"
  source_dir = "/data1/batch/exports/#{batch}"
  puts "Bagging from #{source_dir}..."
  Dir.mkdir bag_dir unless Dir.exist? bag_dir
  Dir.chdir(source_dir)
  Dir.glob('*.nt').each do |item|
    pid = get_short_pid(item)
    list = Dir.glob("*#{pid}*")
    make_bag(bag_dir, source_dir, list, pid)
    if validate_list(list)
      puts "bagged #{pid}"
    else
      puts "no content file included for #{pid}"
    end
  end
  puts "Completed bagging."
end

def make_bag(dir, source_dir, list, pid)
  bag = BagIt::Bag.new(File.join(dir, pid))

  list.each do |item|
    bag.add_file(item, File.join(source_dir, item) ) #relativepathtobag, srcpath
  end
  bag.tagmanifest!
  bag.manifest!
end

def get_short_pid(filename)
  pid = /[a-z0-9]{9}/.match filename
  pid.to_s.gsub("oregondigital-", "") unless pid.nil?
end

def validate_list(list)
  list.join.include? "content"
end
