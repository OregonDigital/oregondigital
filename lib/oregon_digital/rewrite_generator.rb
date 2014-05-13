module OregonDigital
  class RewriteGenerator
    def self.call
      new.write_file
    end

    def replaces_hash
      replaces_objects.map{|hsh| {hsh["id"] => uri_to_id(hsh[replaces_key].first)}}.inject(&:merge) || {}
    end

    def replace_strings
      @replaces_strings ||= replaces_hash.map{|id, value| build_replace_string(id,value)}
    end

    def write_file
      return if replace_strings.blank?
      File.open(output_directory.join(file_name), 'w') do |file|
        replace_strings.each do |string|
          file.puts string
        end
      end
    end

    private

    def output_directory
      Rails.root.join("tmp")
    end

    def file_name
      "hydra_rewrite_rules.conf"
    end

    def build_replace_string(id, value)
      root, pointer = value.split(",")
      "if ($request_uri = /cdm4/item_viewer.php?CISOROOT=#{root}&CISOPTR=#{pointer}&CISOBOX=1&REC=1 ) { rewrite ^ /catalog/#{id}? permanent; }"
    end

    def replaces_objects
      Blacklight.solr.get("select", :params => {:fl => "id,#{replaces_key}", :q => "#{replaces_key}:[* TO *]", :rows => 10000, :qt => "search"})["response"]["docs"]
    end

    def replaces_key
      Solrizer.solr_name("desc_metadata__replacesUrl", :symbol)
    end

    def uri_to_id(uri)
      ("/"+uri.split("u?").last).gsub("//","/")
    end
  end
end
