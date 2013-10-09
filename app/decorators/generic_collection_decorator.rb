class GenericCollectionDecorator < Draper::Decorator
  delegate_all

  def title
    if object.title.blank?
      object.pid
    else
      object.title
    end
  end
end