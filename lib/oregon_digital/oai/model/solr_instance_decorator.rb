class OregonDigital::OAI::Model::SolrInstanceDecorator < Draper::Decorator

    delegate_all
    attr_accessor :modified_date

end 
