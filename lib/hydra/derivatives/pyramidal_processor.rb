require 'vips'
require 'filemagic'
class Hydra::Derivatives::PyramidalProcessor < Hydra::Derivatives::Image

  def process
    directives.each do |name, args|
      opts = args.kind_of?(Hash) ? args : {}
      quality = opts.fetch(:quality, 75)
      tile_size = opts.fetch(:tile_size, 256)
      output_datastream_name = opts.fetch(:datastream, output_datastream_id(name))
      create_pyramidal_image(output_datastream(output_datastream_name), quality, tile_size)
    end
  end

  def create_pyramidal_image(output_datastream, quality, tile_size)
    dimensions = [tile_size, tile_size]
    extension = extract_extension(source_datastream)
    # Can't build tiffs from memory with VIPS. =(
    output_path = Dir::Tmpname.create(["#{source_datastream.pid}",".#{extension}"], Hydra::Derivatives.temp_file_base){}
    source_datastream.to_tempfile do |f|
      VIPS::Image.new(f.path).tiff(output_path,
                                   :compression  => :jpeg,
                                   :layout       => :tile,
                                   :multi_res    => :pyramid,
                                   :quality      => quality,
                                   :tile_size    => dimensions
      )
    end
    output_datastream.content = File.read(output_path)
    File.delete(output_path) if File.exist?(output_path)
  end

  private

  def extract_extension(source_datastream)
    fm = FileMagic.new(FileMagic::MAGIC_MIME)
    mime_type = fm.buffer(source_datastream.content).split(';')[0]
    MIME::Types[mime_type].first.extensions.first
  end

end