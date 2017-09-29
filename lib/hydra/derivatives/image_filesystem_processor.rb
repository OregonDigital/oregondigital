class Hydra::Derivatives::ImageFilesystemProcessor < Hydra::Derivatives::Image

  def process
    directives.each do |name, args|
      opts = args.kind_of?(Hash) ? args : {size: args}
      format = opts.fetch(:format, 'png')
      output_datastream_name = opts.fetch(:datastream, output_datastream_id(name))
      create_resized_image(output_datastream(output_datastream_name), opts[:size], format, opts[:quality], opts[:file_path])
    end
  end

  def source_datastream
    result = super
    return result if result.controlGroup != "E"
    if result.content == "external"
      @source_datastream = OpenStruct.new("controlGroup" => "M","content" => File.open(result.dsLocation.gsub('file://',''),'rb'))
    end
    return @source_datastream
  end

  protected

  def create_resized_image(output_datastream, size, format, quality=nil,file_path=nil)
    create_image(output_datastream, format, quality, file_path) do |xfrm|
      xfrm.resize(size) if size.present?
    end
    output_datastream.mimeType = new_mime_type(format)
  end

  def create_image(output_datastream, format, quality=nil, file_path=nil)
    xfrm = load_image_transformer
    yield(xfrm) if block_given?
    xfrm.format (format) do |c|
      c.auto_orient
      c.args.join(" ")
    end
    xfrm.quality(quality.to_s) if quality
    write_image(output_datastream, xfrm, file_path)
  end

  def write_image(output_datastream, xfrm, file_path)
    case output_datastream.controlGroup
      when "M" then super(output_datastream, xfrm)
      when "E" then store_external(output_datastream, xfrm, file_path)
    end
  end

  def store_external(output_datastream, xfrm, file_path)
    FileUtils.mkdir_p(File.dirname(file_path))
    xfrm.write(file_path)
    output_datastream.dsLocation = "file://#{file_path}"
  end
end
