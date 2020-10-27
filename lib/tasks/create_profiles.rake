# For use as part of verification process in migrating assets from oregondigital
# Requires a list of pids, one pid per line
# to call: bundle exec rake create_profiles pids=/data1/batch/profiles/pidlist.txt export_path=/data1/batch/profiles


INDENT = "  "
DASH = "- "

desc 'Create asset profile yml file' 
task create_profiles: :environment do
  begin
    export_path = ENV['export_path']
    pidlist.each do |pid|
      f = File.open("#{export_path}/#{cleanpid(pid)}_profile.yml", 'w')
      item = GenericAsset.find(pid)
      f.puts "sets:"
      f.print assemble_sets(item.descMetadata.set)
      f.print assemble_primary(item.descMetadata.primarySet)
      f.print assemble_contents(item.descMetadata.od_content) unless item.descMetadata.od_content.blank?
      f.puts "checksums:"
      f.print assemble_checksums(item.datastreams['content'].content) unless no_content?(item)
      f.puts "derivatives_info:"
      f.print assemble_derivatives_info(item.datastreams) if external_datastreams(item.datastreams).present?
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
    puts e.backtrace.join("\n")
  end
end

def pidlist
  arr = []
  File.readlines(ENV['pids']).each do |line|
    arr << line.strip
  end
  arr
end

def no_content?(item)
  return true if item.datastreams['content'].blank?

  return true if !item.descMetadata.od_content.empty? && asset_mimetype(item) == 'xml'

  false
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

def assemble_derivatives_info(datastreams)
  derivatives = external_datastreams(datastreams)
  str = "#{INDENT}has_thumbnail: #{derivatives.include? 'thumbnail'}\n"
  str += "#{INDENT}has_content_ocr: #{derivatives.include? 'content_ocr'}\n"
  str += "#{INDENT}page_count: #{derivatives.select { |d| d.start_with? 'page' }.count}\n"
  str += "#{INDENT}has_content_ogg: #{derivatives.include? 'content_ogg'}\n"
  str += "#{INDENT}has_content_mp3: #{derivatives.include? 'content_mp3'}\n"
  str += "#{INDENT}has_medium_image: #{derivatives.include? 'medium'}\n"
  str += "#{INDENT}has_pyramidal_image: #{derivatives.include? 'pyramidal'}\n"
  str += "#{INDENT}has_content_mp4: #{derivatives.include? 'content_mp4'}\n"
  str += "#{INDENT}has_content_jpg: #{derivatives.include? 'content_jpg'}\n"
  str
end

def external_datastreams(input)
  input.select { |_k, v| v.controlGroup == 'E' }.map { |k, _v| k }
end

def assemble_contents(contents)
  str = "contents:\n"
  contents.each do |content|
    str += "#{DASH}#{content.pid.gsub("oregondigital:", "")}\n"
  end
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
  item.resource.fields - [:primarySet, :set, :od_content]
end

def cleanpid(pid)
  pid.gsub("oregondigital:", "")
end

def extract(val)
  val.respond_to?(:rdf_subject) ? escape_chars(val.rdf_subject.to_s) : escape_chars(val.to_s)
end

def escape_chars(val)
  val.gsub("\"", "\\\"")
end

def asset_mimetype(item)
  item.datastreams['content'].mimeType.split('/').last
end
