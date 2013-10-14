class GenericCollection < GenericAsset
  include OregonDigital::Collection
  def to_param
    OregonDigital::IdService.noidify(pid)
  end
end
