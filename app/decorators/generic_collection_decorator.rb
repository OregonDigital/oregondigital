class GenericCollectionDecorator < Draper::Decorator
  delegate_all

  def title
    if object.title.blank?
      object.pid
    else
      object.title
    end
  end

  def institution_class
    descMetadata.institution.first.try(:rdf_label).try(:first).split('/').last
  end
end
