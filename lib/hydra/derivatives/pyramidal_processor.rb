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
    temp_file_name = "#{source_datastream.pid}_tmp.#{extension}"
    temp_file = Tempfile.new(temp_file_name)
    temp_file.binmode
    temp_file.write(source_datastream.content)
    temp_file.close
    path = "#{path(output_datastream)}.tiff"
    VIPS::Image.new(temp_file.path).tiff(path,
                                       :compression  => :jpeg,
                                       :layout       => :tile,
                                       :multi_res    => :pyramid,
                                       :quality      => quality,
                                       :tile_size    => dimensions
    )
    output_datastream.content = File.read(path)
    temp_file.unlink
    File.delete(path) if File.exist?(path)
  end

  private

  def extract_extension(source_datastream)
    fm = FileMagic.new(FileMagic::MAGIC_MIME)
    mime_type = fm.buffer(source_datastream.content).split(';')[0]
    MIME::Types[mime_type].first.extensions.first
  end

  # Gets path from a Tempfile - I would love to be able to generate this without actually making the file.
  def path(output_datastream)
    t = Tempfile.new("#{source_datastream.dsid}-#{output_datastream.dsid}_tmp.tmp")
    path = t.path
    t.close
    t.unlink
    return path
  end

end