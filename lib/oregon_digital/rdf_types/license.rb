module OregonDigital
  module RdfTypes
    class License < RdfResource
      property :title, :predicate => RDF::DC.title, :type => RDF::Literal do |index|
        index.as :displayable, :facetable
      end
    end
  end
end
