# For use as part of verification process in migrating assets from oregondigital
# Requires a list of pids, one pid per line
# to call: bundle exec rake create_profiles pids=/data1/batch/profiles/pidlist.txt export_path=/data1/batch/profiles


INDENT = "  "
DASH = "- "

desc 'Create asset profile yml file' 
task create_profiles: :environment do
  begin
    export_path = ENV['export_path']
    pids.each do |pid|
      f = File.open("#{export_path}/#{cleanpid(pid)}_profile.yml", 'w')
      item = GenericAsset.find(pid)
      f.puts "sets:"
      f.print assemble_sets(item.descMetadata.set)
      f.print assemble_primary(item.descMetadata.primarySet)
      f.puts "checksums:"
      f.print assemble_checksums(item.datastreams['content'].content) unless item.datastreams["content"].blank?
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
end

def pids
  arr = []
  File.readlines(ENV['pids']).each do |line|
    arr << line.strip
  end
  arr
end

def assemble_checksums(content)
  str = "#{INDENT}SHA1hex:\n"
  str += "#{INDENT}#{DASH}#{Digest::SHA1.hexdigest content}\n"
  str += "#{INDENT}SHA1base64:\n"
  str += "#{INDENT}#{DASH}#{Digest::SHA1.base64digest content}\n"
  str += "#{INDENT}MD5hex:\n"
  str += "#{INDENT}#{DASH}#{Digest::MD5.hexdigest content}\n"
  str += "#{INDENT}MD5base64:\n"
  str += "#{INDENT}#{DASH}#{Digest::MD5.base64digest content}\n"
  str
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
  str + "#{primary}\n"
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
