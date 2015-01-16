require 'vips'
require 'filemagic'
class Hydra::Derivatives::PyramidalProcessor < Hydra::Derivatives::Image

  def process
    directives.each do |name, args|
      opts = args.kind_of?(Hash) ? args : {}
      tiff_file = nil
      source_datastream.to_tempfile { |f| tiff_file = create_pyramidal_image(f, opts) }
      create_datastream(tiff_file, name, opts)
    end
  end

  def create_pyramidal_image(file, opts)
    quality = opts.fetch(:quality, 75)
    tile_size = opts.fetch(:tile_size, 256)
    dimensions = [tile_size, tile_size]
    source_pid = source_datastream.pid

    # Can't build tiffs from memory with VIPS. =(
    output_path = Dir::Tmpname.create(["#{source_pid}",".tiff"], Hydra::Derivatives.temp_file_base){}
    i = VIPS::Image.new(file.path)
    # Can't convert 16 bit tiffs the traditional way - make it a jpeg first.
    if i.vtype.to_s == "RGB16" || i.vtype.to_s == "GREY16"
      i = i.msb
    end
    i.tiff(output_path,
      :compression  => :jpeg,
      :layout       => :tile,
      :multi_res    => :pyramid,
      :quality      => quality,
      :tile_size    => dimensions
    )

    raise "Unable to store pyramidal TIFF for #{source_pid}!" if !File.exist?(output_path)

    return output_path
  end

  # Dispatches to the appropriate datastream creation method based on datastream control group
  def create_datastream(tiff_file, name, opts)
    ds = output_datastream(opts.fetch(:datastream, output_datastream_id(name)))
    ds.mimeType = "image/tiff"

    case ds.controlGroup
      when "M" then store_managed_datastream(ds, tiff_file)
      when "E" then store_external_datastream(ds, tiff_file, opts)
    end
  end

  def store_managed_datastream(ds, tiff_file)
    ds.content = File.read(tiff_file)
    File.delete(tiff_file)
  end

  # Moves the temporary tiff file and stores location metadata on the stream so Fedora knows how
  # to serve up the file if necessary
  def store_external_datastream(ds, tiff_file, opts)
    file_path = opts[:file_path]
    FileUtils.mkdir_p(File.dirname(file_path))
    FileUtils.mv(tiff_file, file_path)
    ds.dsLocation = "file://#{file_path}"
  end
end
