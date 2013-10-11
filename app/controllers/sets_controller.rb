class SetsController < CatalogController
  def index
    @collections = GenericCollectionDecorator.decorate_collection(GenericCollection.all)
    @collection = @collections.find{|x| x.pid.downcase == OregonDigital::IdService.namespaceize(params[:set]).downcase}
    super
  end
end
