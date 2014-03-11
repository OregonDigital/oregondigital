# Subclasses association from gem to add method and attribute for cloning
class OregonDigital::Metadata::CloneableAssociation < Metadata::Ingest::Association
  attr_accessor :clone

  def initialize(args = {})
    # Web checkboxes come in like this, so this horrific "boolean cast" is NOT
    # my fault!
    @clone = "1" == args.delete(:clone)
    super
  end

  def cloneable?
    return true
  end
end
