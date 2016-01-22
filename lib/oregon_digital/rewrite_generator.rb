module OregonDigital
  class RewriteGenerator
    def self.call
      new.write_file
    end

    def replaces_hash
      replaces_objects.map{|hsh| {hsh["id"] => uri_to_id(hsh[replaces_key].first)}}|| {}
    end

    def replace_strings
      @replaces_strings ||= replaces_hash.map{|hsh| build_replace_string(hsh.keys.first,hsh.values.first)}.flatten
    end

    def write_file
      return if replace_strings.blank?
      File.open(output_directory.join(file_name), 'w') do |file|
        replace_strings.each do |strings|
          Array(strings).each do |string|
            file.puts string
          end
        end
      end
      puts "Wrote #{replace_strings.length} rewrite rules to #{output_directory.join(file_name)}"
    end

    private

    def output_directory
      Rails.root.join("tmp")
    end

    def file_name
      "oregondigital.map"
    end

    def build_replace_string(id, value)
      root, pointer = value.split(",")
      [viewer_string(root,pointer,id), persistent_url_string(root, pointer, id)]
    end

    def viewer_string(root, pointer,id)
      "~*/cdm4/item_viewer\\.php\\?CISOROOT=#{root}&CISOPTR=#{pointer}&.*$ \"#{id.gsub("oregondigital:","")}\";"
    end

    def persistent_url_string(root, pointer, id)
      "~*/u/\\?#{root},#{pointer}$ \"#{id.gsub("oregondigital:","")}\";"
    end

    def replaces_objects
      Blacklight.solr.get("select", :params => {:fl => "id,#{replaces_key}", :q => "#{replaces_key}:[* TO *] #{reviewed_key}:true", :rows => max_item_count, :qt => "search"})["response"]["docs"]
    end

    def max_item_count
      1000000
    end

    def reviewed_key
      ActiveFedora::SolrService.solr_name(:reviewed, :symbol)
    end

    def replaces_key
      Solrizer.solr_name("desc_metadata__replacesUrl", :symbol)
    end

    def uri_to_id(uri)
      ("/"+uri.split("u?").last).gsub("//","/")
    end
  end
end
