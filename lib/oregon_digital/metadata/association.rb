# Subclasses association from gem to add method which tells forms not to show
# the "clone" checkbox
class OregonDigital::Metadata::Association < Metadata::Ingest::Association
  def cloneable?
    return false
  end
end
