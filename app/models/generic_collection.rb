class GenericCollection < GenericAsset

  def to_param
    self.class.id_param(pid)
  end

  private

  def self.id_param(id)
    OregonDigital::IdService.noidify(id)
  end

end
