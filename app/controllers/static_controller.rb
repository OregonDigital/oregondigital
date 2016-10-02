class StaticController < ApplicationController

  def controlled_vocabularies
    @controlled_vocabs = []

    Datastream::OregonRDF.properties.map do |key, property|
      next if property[:class_name].nil?
      next if property[:class_name].to_s == "GenericAsset" || property[:class_name].to_s == "GenericCollection"

      @controlled_vocabs << property[:class_name]
    end 

    @controlled_vocabs = @controlled_vocabs.uniq
  end
end
