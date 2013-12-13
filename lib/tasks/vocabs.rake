
require 'linkeddata'
require 'rdf/cli/vocab-loader'

desc "Generate Vocabularies"
vocab_sources = {
  :dcmitype =>  { :prefix => 'http://purl.org/dc/dcmitype/', :source => 'http://dublincore.org/2012/06/14/dctype.rdf' },
  :marcrel  =>  { :prefix => 'http://id.loc.gov/vocabulary/relators/', :source => 'http://id.loc.gov/vocabulary/relators.nt' },
  # :dwc      =>  { :prefix => 'http://rs.tdwg.org/dwc/terms/', :source => 'http://rs.tdwg.org/dwc/rdf/dwcterms.rdf' },
  :premis   =>  { :prefix => 'http://www.loc.gov/premis/rdf/v1#', :source => 'http://www.loc.gov/premis/rdf/v1.nt' },
}

task :gen_vocabs => :environment do
  vocab_sources.each do |id, v|
    puts "Generate lib/oregon_digital/vocabularies/#{id}.rb"
    begin
      out = StringIO.new
      loader = OregonDigital::RDF::VocabularyLoader.new(id.to_s.upcase)
      loader.prefix = v[:prefix]
      loader.source = v[:source] if v[:source]
      loader.extra = v[:extra] if v[:extra]
      loader.strict = v.fetch(:strict, true)
      loader.output = out
      loader.run
      out.rewind
      File.open("lib/oregon_digital/vocabularies/#{id}.rb", "w") {|f| f.write out.read}
    rescue
      puts "Failed to load #{id}: #{$!.message}"
    end
  end
end
