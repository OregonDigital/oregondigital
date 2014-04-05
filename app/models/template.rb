# Special subclass of assets specifically built to hold pre-filled form data
class Template < GenericAsset
  has_metadata :name => 'templateMetadata', :type => Datastream::OregonRDF
  after_initialize :redefine_resource_class
  validates :title, presence: true

  def self.all_sorted
    return all.sort_by {|t| t.title.downcase}
  end

  private

  # Sets @needs_derivatives to false to ensure templates never accidentally do
  # anything we wouldn't want
  def check_derivatives
    @needs_derivatives = false
    return true
  end

  def redefine_resource_class
    templateMetadata.singleton_class.define_singleton_method :resource_class do
      OregonDigital::RDF::TemplateResource
    end
  end
end
