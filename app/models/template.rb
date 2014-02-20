# Special subclass of assets specifically built to hold pre-filled form data
class Template < GenericAsset
  has_metadata :name => 'templateMetadata', :type => Datastream::Yaml
  validates :name, presence: true

  def self.all_sorted
    return all.sort_by {|t| t.name.downcase}
  end

  def name
    return @name || templateMetadata.name || title
  end

  def name=(val)
    templateMetadata.name = @name = val
  end

  private

  # Sets @needs_derivatives to false to ensure templates never accidentally do
  # anything we wouldn't want
  def check_derivatives
    @needs_derivatives = false
    return true
  end
end
