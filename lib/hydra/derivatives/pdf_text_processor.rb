module Hydra::Derivatives
  class PdfTextProcessor < Processor
    include ShellBasedProcessor

    def self.encode(file_path, options, output_file)
      execute "pdftotext -enc UTF-8 '#{file_path}' '#{output_file}' -bbox"
    end

    def options_for(format)
      {:output_file => object.ocr_location}
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

    def new_mime_type(format)
      return "text/html" if format.to_sym == :html
      super
    end
  end
end
