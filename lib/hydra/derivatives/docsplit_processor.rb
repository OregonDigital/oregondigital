require 'docsplit'
require 'filemagic'

class Hydra::Derivatives::DocsplitProcessor < Hydra::Derivatives::Processor
  def process
    directives.each do |name, args|
      opts = args.kind_of?(Hash) ? args : {}
      format = opts.fetch(:format, 'png')
      sizes = opts.fetch(:sizes, default_sizes)
      output_path = Pathname.new(opts.fetch(:output_path, File.join(Hydra::Derivatives.temp_file_base,source_datastream.pid.split(":").last)))
      split_images(format, sizes, output_path)
    end
  end

  def default_sizes
    {
        'large' => '1000x',
        'normal' => '700x',
        'small' => '180x'
    }
  end

  def split_images(format, sizes, output_path)
    extension = extract_extension(source_datastream)
    source_datastream.to_tempfile do |f|
      path = Pathname.new(f.path)
      new_path = Pathname.new(path.sub_ext(".#{extension}").to_s.gsub(":", "-"))
      File.rename(path.to_s,new_path.to_s)
      begin
        f = File.open(new_path)
        FileUtils.rm_rf(output_path)
        FileUtils.mkdir_p(output_path)
        Docsplit.extract_images(f.path, :size => default_sizes['large'], :format => format, :output => output_path)
        Dir["#{output_path.join('*')}"].each do |file|
          page = Pathname.new(file.split('_').last).sub_ext('').to_s
          page_path = Pathname.new(file)
          new_path = File.join(output_path, "page-#{page}#{page_path.extname}")
          File.rename(file, new_path.to_s)
          output_datastream("page-#{page}").controlGroup = "E"
          output_datastream("page-#{page}").content = "external"
          output_datastream("page-#{page}").dsLocation = "file://#{new_path.to_s}"
        end
      ensure
        File.unlink(f.path) if File.exist?(f.path)
      end
    end
  end

  private

  def extract_extension(source_datastream)
    fm = FileMagic.new(FileMagic::MAGIC_MIME)
    mime_type = fm.buffer(source_datastream.content).split(';')[0]
    MIME::Types[mime_type].first.extensions.first
  end

end
