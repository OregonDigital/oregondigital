class Documents::Paged < Documents::Base

  makes_derivatives do |obj|
    obj.transform_datastream :content, {:pages => ''}, :processor => :docsplit_processor
  end

end