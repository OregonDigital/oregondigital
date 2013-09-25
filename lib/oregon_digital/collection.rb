module OregonDigital
  module Collection
    extend ActiveSupport::Concern

    included do
      has_many :members, :property => :is_member_of_collection, :class_name => "ActiveFedora::Base"
    end

  end
end
