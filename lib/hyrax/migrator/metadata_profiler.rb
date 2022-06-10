
module Hyrax::Migrator

  module MetadataProfiler
    INDENT = "  "
    DASH = "- "

    def create_profile(export_path, item, graph, configs_path)
      @configs_path = configs_path
      f = File.open(File.join(export_path, "#{cleanpid(item.pid)}_profile.yml"), 'w')
      f.puts "sets:"
      f.print assemble_sets(graph)
      f.print assemble_primary(graph)
      f.print assemble_contents(graph)
      f.puts "derivatives_info:"
      f.print assemble_derivatives_info(item.datastreams)
      f.print visibility(item)
      f.puts "fields:"
      f.print assemble_fields(graph)
      f.close
    rescue StandardError => e
      puts e.message
      puts e.backtrace.join("\n")
    end

    def assemble_fields(graph)
      big_string = ""
      property_hash.keys.each do |k|
        vals = graph.statements.select{ |s| s.predicate == RDF::URI(property_hash[k])}.map{|s| s.object }
        next if vals.blank?

        big_string += assemble_field(k, vals)
      end
      big_string
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

    def assemble_contents(graph)
      contents = query_graph(graph, 'contents')
      return if contents.blank?

      str = "contents:\n"
      contents.each do |content|
        str += "#{INDENT}#{DASH}#{content}\n"
      end
      str
    end

    def assemble_sets(graph)
      str = "#{INDENT}set:\n"
      query_graph(graph, 'set').each do |set|
        str += "#{INDENT}#{DASH}#{set}\n"
      end
      str
    end

    def assemble_primary(graph)
      str = "#{INDENT}primarySet: "
      primary = query_graph(graph, 'primarySet').first || ""
      str + "#{primary}\n"
    end

    def assemble_field(field, vals)
      return assemble_field_single(field, vals) unless prop_is_array? field.to_sym

      str = "#{INDENT}#{field}:\n"
      vals.each do |v|
        str += "#{INDENT}#{DASH}\"#{extract(v)}\"\n"
      end
      str
    end

    def assemble_field_single(field, val)
      v = val.is_a?(Array) ? val.first : val
      "#{INDENT}#{field}: \"#{extract(v)}\"\n"
    end
  
    def query_graph(graph, term)
      pids = []
      statements = graph.query(:predicate => RDF::URI("http://opaquenamespace.org/ns/#{term}"))
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

    def visibility(item)
      str = "visibility:\n"
      visibility = item.read_groups - ['admin', 'archivist']
      visibility.each do |v|
        str += "#{INDENT}#{DASH} \"#{v}\"\n"
      end
      str
    end

    # check if property is an array in OD2
    def prop_is_array?(property)
      is_multiple?(property_hash[property])
    end

    def is_multiple?(predicate)
      @lookup ||= crosswalk_service.crosswalk_hash.select{|k| k[:multiple] == false }.map{ |k| k[:predicate] }
      !@lookup.include? predicate
    end

    def crosswalk_service
      Hyrax::Migrator::CrosswalkMetadata.new(crosswalk_file, crosswalk_overrides_file)
    end

    def crosswalk_file
      File.join(@configs_path, 'crosswalk.yml')
    end

    def crosswalk_overrides_file
      File.join(@configs_path, 'crosswalk_overrides.yml')
    end

    # just do this once
    def property_hash
      @hash ||= get_od_properties
    end

    # returns hash, eg { :title => "http://purl.org/dc/terms/title" }
    def get_od_properties
      hash = {}
      Datastream::OregonRDF.properties.except(:set, :primarySet, :od_content).map{|p| p[1]}.each do |val|
        hash[val.term] = val.predicate.to_s
      end
      hash
    end
  end
end
