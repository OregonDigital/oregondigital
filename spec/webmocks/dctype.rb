RSpec.configure do |config|
  config.before(:each) do
    stub_request(:get, "http://dublincore.org/2012/06/14/dctype.rdf").
      with(:headers => {'Accept'=>'application/n-triples, text/plain;q=0.5, application/rdf+xml, text/html;q=0.5, application/xhtml+xml, image/svg+xml, application/n-quads, text/x-nquads, application/ld+json, application/x-ld+json, application/json, text/n3, text/rdf+n3, application/rdf+n3, application/trig, application/x-trig, application/trix, application/turtle, text/rdf+turtle, text/turtle, application/x-turtle, */*;q=0.1', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => '<http://purl.org/dc/dcmitype/Image> <http://example.org/blah> "blah" .', :headers => {:'Content-Type' => 'application/n-triples'})
  end
end
