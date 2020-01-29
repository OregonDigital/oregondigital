# For use as part of verification process in migrating assets from oregondigital
# to call: bundle exec rake create_profiles pids=mypids, export_path=myexportpath
# where mypids = ['oregondigital:abcde1234']
# and myexportpath = '/data1/batch/profiles'

INDENT = "  "
DASH = "- "

desc 'Create asset profile yml file' 
task create_profile: :environment do
  export_path = ENV['export_path']
  pids = ENV['pids']
  pids.each do |pid|
    f = File.open("#{export_path}/#{cleanpid(pid)}_profile.yml", 'w')
    item = GenericAsset.find(pid)
    f.puts "sets:"
    f.print assemble_sets(item.descMetadata.set)
    f.print assemble_primary(item.descMetadata.primarySet)
    f.puts "fields:"
    fields(item).each do |field|
      vals = item.descMetadata.send(field)
      next if vals.blank?
      f.print assemble_field(field, vals)
    end
    f.close
  end
rescue StandardError => e
  puts e.message
end

def assemble_sets(sets)
  str = "#{INDENT}set:\n"
  sets.each do |set|
    str += "#{INDENT}#{DASH}#{set.pid}\n"
  end
  str
end

def assemble_primary(primary_set)
  str = "#{INDENT}primarySet: "
  primary = primary_set.blank? ? "" : primary_set.first.pid
  str += "#{primary}\n"
end

def assemble_field(field, vals)
  str = "#{INDENT}#{field}:\n"
  return str + "#{INDENT}#{field}: \"#{extract(vals)}\"\n" unless vals.is_a? Array

  vals.each do |v|
    str += "#{INDENT}#{DASH}\"#{extract(v)}\"\n"
  end
  str
end

def fields(item)
  item.resource.fields - [:primarySet, :set]
end

def cleanpid(pid)
  pid.gsub("oregondigital:", "")
end

def extract(val)
  val.respond_to?(:rdf_subject) ? val.rdf_subject.to_s : val
end

