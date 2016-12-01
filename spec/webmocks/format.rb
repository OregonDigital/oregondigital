RSpec.configure do |config|
  config.before(:each) do
    # this stubs a different URI due to the custom fetch method in the Format controlled vocabulary
    # that handles the redirect from the original w3id.org URI
    stub_request(:get, "http://www.sparontologies.net/mediatype/image/tiff.rdf").
      with(:headers => {'Accept'=>'application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => lambda {|request| "<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#' xmlns:rdfs='http://www.w3.org/2000/01/rdf-schema#'><rdf:Description rdf:about='https://w3id.org/spar/mediatype/image/tiff'><rdfs:label>image/tiff</rdfs:label></rdf:Description></rdf:RDF>"}, :headers => {:'Content-Type' => 'application/xml'})
  end
end

