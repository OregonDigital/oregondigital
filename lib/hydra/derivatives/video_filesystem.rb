module Hydra::Derivatives
  class VideoFilesystem < Video
    def options_for(format)
      {
        :output_file => object.send("#{format}_location")
      }.merge(super)
    end

    def encode_datastream(dest_dsid, file_suffix, mime_type, options = '')
      output_file = options[:output_file]
      FileUtils.mkdir_p(Pathname.new(output_file).dirname)
      options = nil
      source_datastream.to_tempfile do |f|
        self.class.encode(f.path, options, output_file)
      end
      ds = output_datastream(dest_dsid)
      ds.dsLocation = "file://#{output_file}"
      ds.controlGroup = "E"
      ds.mimeType = mime_type
      ds.content = "external"
    end
  end
end
