module OregonDigital
  module Catalog

    # This module is for decorators which give us better view logic without hacking Blacklight,
    # instantiating objects in the views, etc.
    module Decorators
      extend ActiveSupport::Concern
      included do
        def decorated_object
          @document_object ||= ActiveFedora::Base.load_instance_from_solr(params[:id], @document)
          begin
            @decorated_object ||= @document_object.decorate
          rescue Draper::UninferrableDecoratorError
            @decorated_object = GenericAssetDecorator.new(@document_object)
          end

          return @decorated_object
        end

        helper_method :decorated_object
      end
    end
  end
end
