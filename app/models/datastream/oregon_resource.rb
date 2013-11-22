class Datastream::OregonResource < Datastream::NtResourceDatastream
  property :title, :predicate => RDF::DC[:title], :class_name => RDF::Literal do |index|
    index.as :searchable, :displayable
  end
  property :creator, :predicate => RDF::DC11[:creator] do |index|
    index.as :searchable, :displayable, :facetable
  end
  property :contributor, :predicate => RDF::DC11[:contributor] do |index|
    index.as :searchable, :displayable, :facetable
  end
  property :abstract, :predicate => RDF::DC[:abstract] do |index|
    index.as :searchable, :displayable
  end
  property :description, :predicate => RDF::DC[:description] do |index|
    index.as :searchable, :displayable
  end
  property :dce_subject, :predicate => RDF::DC11[:subject] do |index|
    index.as :searchable, :displayable, :facetable
  end
  property :source, :predicate => RDF::DC11[:source] do |index|
    index.as :displayable
  end
  property :dce_type, :predicate => RDF::DC11[:type] do |index|
    index.as :displayable
  end
  property :spatial_coverage, :predicate => RDF::DC11[:coverage] do |index|
    index.as :displayable
  end
  property :location, :predicate => RDF::DC[:spatial] do |index|
    # :class_name => OregonDigital::RdfTypes::Location
    index.as :displayable
  end
  property :rights, :predicate => RDF::DC11[:rights] do |index|
    index.as :displayable
  end
  property :license, :predicate => RDF::DC[:license], :class_name =>
    OregonDigital::RdfTypes::License do |index|
    index.as :searchable, :displayable
  end
end
