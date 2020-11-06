RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, /https?:\/\/id\.loc\.gov\/authorities\/subjects\/sh.*/).
      with(:headers => {'Accept'=>'application/n-triples, text/plain;q=0.5, application/rdf+xml, text/html;q=0.5, application/xhtml+xml, image/svg+xml, application/n-quads, text/x-nquads, application/ld+json, application/x-ld+json, application/json, text/n3, text/rdf+n3, application/rdf+n3, application/trig, application/x-trig, application/trix, application/turtle, text/rdf+turtle, text/turtle, application/x-turtle, */*;q=0.1', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => lambda {|request| "<#{request.uri.to_s.gsub(":80","").gsub(":443","").gsub("https","http")}> <http://www.w3.org/2004/02/skos/core#prefLabel> \"Food industry and trade\"@en .'"}, :headers => {:'Content-Type' => 'application/n-triples'})
  end
end
