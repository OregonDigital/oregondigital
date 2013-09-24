require 'docsplit'
require 'filemagic'

class Hydra::Derivatives::DocsplitProcessor < Hydra::Derivatives::Processor
  def process
    directives.each do |name, args|
      opts = args.kind_of?(Hash) ? args : {}
      format = opts.fetch(:format, 'png')
      sizes = opts.fetch(:sizes, default_sizes)
      split_images(format, sizes)
    end
  end

  def default_sizes
    {
        'large' => '1000x',
        'normal' => '700x',
        'small' => '180x'
    }
  end

  def split_images(format, sizes)
    extension = extract_extension(source_datastream)
    output_path = Pathname.new(File.join(Hydra::Derivatives.temp_file_base,source_datastream.pid.split(":").last))
    begin
      source_datastream.to_tempfile do |f|
        path = Pathname.new(f.path)
        File.rename(path.to_s,path.sub_ext(".#{extension}").to_s)
        begin
          f = File.open(path.sub_ext(".#{extension}"))
          sizes.each do |name, size|
            Docsplit.extract_images(f.path, :size => size, :format => format, :output => output_path.join(name))
            Dir["#{output_path.join(name,'*')}"].each do |file|
              page = Pathname.new(file.split('_').last).sub_ext('').to_s
              output_datastream("#{name}-#{page}").content = File.read(file)
            end
          end
        ensure
          File.unlink(f.path) if File.exist?(f.path)
        end
      end
    ensure
      FileUtils.rm_rf(output_path) if File.exist?(output_path)
    end
  end

  private

  def extract_extension(source_datastream)
    fm = FileMagic.new(FileMagic::MAGIC_MIME)
    mime_type = fm.buffer(source_datastream.content).split(';')[0]
    MIME::Types[mime_type].first.extensions.first
  end

end