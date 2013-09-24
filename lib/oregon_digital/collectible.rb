require 'active_fedora'

module OregonDigital
  module Collectible
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :collections, :property => :is_member_of_collection, :class_name => "ActiveFedora::Base"
    end
  end
end
