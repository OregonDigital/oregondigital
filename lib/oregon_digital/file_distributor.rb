# Determines a file path for an identifier (object pid, for instance), using a "bucket" directory
# structure of a configurable depth.
class OregonDigital::FileDistributor
  attr_accessor :base_path, :identifier, :depth, :extension

  # Sets up object with a default depth of 2 and a local base path
  def initialize(identifier)
    @identifier = identifier.to_s
    @depth = 2
    @base_path = Rails.root.join("media")
    @extension = ''
  end

  def base_path=(val)
    @base_path = Pathname.new(val)
  end

  # Sanitizes @identifier (converts all non-alphanumerics to hyphens) and returns a "safe" filename
  def filename
    return @identifier.gsub(/\W/, '-')+extension
  end

  # Creates a path @depth subdirectories deep to represent a "bucket"-style directory structure,
  # prefixing with base_path.  Zero-pads the identifier if it's too short.
  def path
    reversed = (filename.rjust(@depth, "0")).reverse.split(//)
    bucket_path = (["%s"] * @depth).join("/") % reversed
    return @base_path.join(bucket_path, filename).to_s
  end
end
