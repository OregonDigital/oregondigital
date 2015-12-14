class OregonDigital::OAI::Model::SolrInstanceDecorator < Draper::Decorator

    delegate_all
    attr_accessor :modified_date, :identifier, :sets

    #override fields that return uris to return labels
    def set_attrs (key, val)
      self.instance_variable_set("@#{key}", val)
      self.class.send(:define_method, key, proc {self.instance_variable_get("@#{key}")})
    end
end
