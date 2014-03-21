class GenericCollection < GenericAsset
  include OregonDigital::Set
  after_initialize :redefine_resource_class

  def self.qa_interface
    OregonDigital::ControlledVocabularies::Set.qa_interface
  end

  def to_param
    self.class.id_param(pid)
  end

  private

  def self.id_param(id)
    OregonDigital::IdService.noidify(id)
  end

  def redefine_resource_class
    descMetadata.singleton_class.define_singleton_method :resource_class do
      OregonDigital::ControlledVocabularies::Set
    end
  end

end
