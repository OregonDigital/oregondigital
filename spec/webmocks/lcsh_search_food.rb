RSpec.configure do |config|
  config.before(:each) do
    uri = "http://id.loc.gov/search/?q=food&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects&format=json"
    raw_response = File.new(Rails.root.join("spec/webmocks/lcsh_search_food.json"))
    stub_request(:get, uri).
      with().
      to_return(
        :status => 200,
        :body => raw_response.read,
        :headers => {
          :"Content-type" => "application/json",
          :"Cache-Control" => "public, max-age=43200",
          :"X-URI" => "http://id.loc.gov/search/mimetype=*/*&q=food&q=cs%3Ahttp%3A%2F%2Fid.loc.gov%2Fauthorities%2Fsubjects&format=json",
          :"Server" => "Apache",
          :"Content-Length" => "50309",
          :"Accept-Ranges" => "bytes",
          :"Date" => "Wed, 15 Jan 2014 17:29:39 GMT",
          :"X-Varnish" => "1916248130",
          :"Age" => "0",
          :"Via" => "1.1 varnish",
          :"Connection" => "keep-alive"
        }
      )
  end
end
