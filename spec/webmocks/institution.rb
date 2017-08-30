RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "http://dbpedia.org/resource/University_of_Oregon").
      with(:headers => {'Accept'=>'application/n-triples, text/plain;q=0.5, application/rdf+xml, text/html;q=0.5, application/xhtml+xml, image/svg+xml, application/n-quads, text/x-nquads, application/ld+json, application/x-ld+json, application/json, text/n3, text/rdf+n3, application/rdf+n3, application/trig, application/x-trig, application/trix, application/turtle, text/rdf+turtle, text/turtle, application/x-turtle, */*;q=0.1', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => lambda {|request| "<#{request.uri.to_s.gsub(":80","")}> <http://purl.org/dc/terms/title> \"University of Oregon\"@en .'"}, :headers => {:'Content-Type' => 'application/n-triples'})
    stub_request(:get, "http://dbpedia.org/data/University_of_Oregon.rdf").
      with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<?xml version="1.0" encoding="utf-8" ?><rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"><rdf:Description rdf:about="http://dbpedia.org/resource/University_of_Oregon"><rdfs:label xml:lang="en">University of Oregon</rdfs:label></rdf:Description></rdf:RDF>', :headers => {:'Content-Type' => 'application/xml'})
  end
end
