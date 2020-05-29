module Hydra::Derivatives
  class VideoFilesystem < Video
    def options_for(format)
      result = {
        :output_file => object.send("#{format}_location")
      }.merge(super)
      output_options = result[Ffmpeg::OUTPUT_OPTIONS] || ''
      output_options += " -v 0 -nostats -y"
      result[Ffmpeg::OUTPUT_OPTIONS] = output_options
      result
    end

    def encode_datastream(dest_dsid, file_suffix, mime_type, options = '')
      output_file = options.delete(:output_file)
      FileUtils.mkdir_p(Pathname.new(output_file).dirname)
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
