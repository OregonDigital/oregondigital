# Special subclass of assets specifically built to hold pre-filled form data
class Template < GenericAsset
  has_metadata :name => 'templateMetadata', :type => Datastream::OregonRDF do |ds|
    ds.crosswalk :field => :set, :to => :is_member_of_collection, :in => "RELS-EXT",
                 :transform => Proc.new {|x| x.gsub('info:fedora/','')},
                 :reverse_transform => Proc.new {|x| "info:fedora/#{x}"}
  end

  validates :name, presence: true

  def self.all_sorted
    return all.sort_by {|t| t.name.downcase}
  end

  def name
    return @name || title
  end

  def name=(val)
    self.title = @name = val
  end

  private

  # Sets @needs_derivatives to false to ensure templates never accidentally do
  # anything we wouldn't want
  def check_derivatives
    @needs_derivatives = false
    return true
  end
end
