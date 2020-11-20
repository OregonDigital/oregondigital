
module Hyrax::Migrator

  module MetadataProfiler
    INDENT = "  "
    DASH = "- "

    def create_profile(export_path, item)
      f = File.open(File.join(export_path, "#{cleanpid(item.pid)}_profile.yml"), 'w')
      f.puts "sets:"
      f.print assemble_sets(item)
      f.print assemble_primary(item)
      f.print assemble_contents(item)
      f.puts "derivatives_info:"
      f.print assemble_derivatives_info(item.datastreams)
      f.puts "fields:"
      fields(item).each do |field|
        vals = item.descMetadata.send(field)
        next if vals.blank?

        f.print assemble_field(field, vals)
      end
      f.close
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
    end

    def assemble_derivatives_info(datastreams)
      derivatives = external_datastreams(datastreams)
      return if derivatives.empty?

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

    def assemble_contents(item)
      contents = query_graph(item, 'content')
      return if contents.blank?

      str = "contents:\n"
      contents.each do |content|
        str += "#{DASH}#{content}\n"
      end
      str
    end

    def assemble_sets(item)
      str = "#{INDENT}set:\n"
      query_graph(item, 'set').each do |set|
        str += "#{INDENT}#{DASH}#{set}\n"
      end
      str
    end

    def assemble_primary(item)
      str = "#{INDENT}primarySet: "
      primary = query_graph(item, 'primarySet').first || ""
      str + "#{primary}\n"
    end

    def assemble_field(field, vals)
      return "#{INDENT}#{field}: \"#{extract(vals)}\"\n" unless vals.is_a? Array

      str = "#{INDENT}#{field}:\n"
      vals.each do |v|
        str += "#{INDENT}#{DASH}\"#{extract(v)}\"\n"
      end
      str
    end
  
    def query_graph(item, term)
      pids = []
      statements = item.descMetadata.graph.query(:predicate => RDF::URI("http://opaquenamespace.org/ns/#{term}"))
      return pids if statements.empty?

      statements.each do |s|
        pids << s.object.to_s.split(':').last
      end
      pids
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
  end
end
