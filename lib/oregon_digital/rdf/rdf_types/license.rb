module OregonDigital::RDF
  module RdfTypes
    class License < ActiveFedora::Rdf::Resource
      configure :repository => :default
      property :title, :predicate => RDF::DC.title, :class_name => RDF::Literal do |index|
        index.as :displayable, :facetable
      end
    end
  end
end
