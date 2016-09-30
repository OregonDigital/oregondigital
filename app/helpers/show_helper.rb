module ShowHelper
  def render_download_links(document)
    if can?(:create, decorated_object.object.class)
      render :partial => "admin_download_links"
    elsif ((can?(:read, decorated_object.object.class))&&(decorated_object.object.read_groups.include? "University-of-Oregon"))
      render :partial => "admin_download_links"
    else
      render :partial => "download_links" unless can?(:create, decorated_object.object.class)
    end
  end
  def download_links(document)
    {"Standard" => download_path(document["id"]),
     "High Resolution" => download_path(document["id"], :datastream_id => "content")
    }
  end
end
