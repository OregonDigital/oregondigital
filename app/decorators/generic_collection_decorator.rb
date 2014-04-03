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
    resource.institution.first.try(:rdf_subject).to_s.split('/').last
  end
end
