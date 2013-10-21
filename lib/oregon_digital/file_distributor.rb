# Determines a file path for an identifier (object pid, for instance), using a "bucket" directory
# structure of a configurable depth.
class OregonDigital::FileDistributor
  attr_accessor :base_path, :identifier, :depth

  # Sets up object with a default depth of 2 and no base path
  def initialize(identifier)
    @identifier = identifier.to_s
    @depth = 2
  end

  # Sanitizes @identifier (converts all non-alphanumerics to hyphens) and returns a "safe" filename
  def filename
    return @identifier.gsub(/\W/, '-')
  end

  # Creates a path @depth subdirectories deep to represent a "bucket"-style directory structure,
  # prefixing with base_path if set.  Zero-pads the identifier if it's too short.
  def path
    reversed = (filename.rjust(@depth, "0")).reverse.split(//)
    directories = Pathname.new((["%s"] * @depth).join("/") % reversed)
    if base_path
      directories = Pathname.new(base_path) + directories
    end
    return directories.join(filename).to_s
  end
end
