module ShowHelper
  def render_download_links(document)
    return standard_download_button(document) unless can?(:create, decorated_object.object.class)
    content_tag("div", :class => "btn-group") do
      link_to("#", :data => {:toggle => "dropdown"}, :class => "btn dropdown-toggle") do
        raw("Download" + content_tag("span", '',  :class => "caret"))
      end + 
      content_tag("ul", :class => "dropdown-menu") do
        download_links(document)
      end
    end
  end
  def standard_download_button(document)
    content_tag("div") do
      link_to "Download", download_path(document["id"]), :class => "btn"
    end
  end
  def download_links(document)
    content_tag("li") do
      link_to "Standard", download_path(document["id"])
    end + 
    content_tag("li") do
      link_to "High Resolution", download_path(document["id"], :datastream_id => "content")
    end
  end
end
