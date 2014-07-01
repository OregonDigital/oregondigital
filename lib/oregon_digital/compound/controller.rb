module OregonDigital::Compound
  module Controller
    extend ActiveSupport::Concern
    included do
      before_filter :compound_parent_redirect
    end

    def compound_parent_redirect
      if decorated_object.compound? && decorated_object.content.blank?
        redirect_to catalog_path(decorated_object.od_content.first.pid)
      end
    end
  end
end
