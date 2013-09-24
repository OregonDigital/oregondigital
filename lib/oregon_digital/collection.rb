module OregonDigital
  module Collection
    extend ActiveSupport::Concern

    included do
      has_many :members, :property => :is_member_of_collection, :class_name => "ActiveFedora::Base"
      before_destroy :remove_all_members
    end

    def remove_all_members
      members.each do |member|
        # TODO: delete members
      end
    end
  end
end
