# Based closely on https://github.com/ruby-rdf/rdf/blob/develop/Rakefile

require 'linkeddata'
require 'rdf/cli/vocab-loader'
require 'oregon_digital/rdf/vocabulary_loader'
require_relative '../../config/initializers/controlled_vocabularies'

desc "Generate Vocabularies"

task :gen_vocabs do
  RDF_VOCABS.each do |id, v|
    puts "Generate lib/oregon_digital/vocabularies/#{id}.rb"
    begin
      out = StringIO.new
      loader = OregonDigital::RDF::VocabularyLoader.new(id.to_s.upcase)
      loader.prefix = v[:prefix]
      loader.source = v[:source] if v[:source]
      loader.extra = v[:extra] if v[:extra]
      loader.fetch = v.fetch(:fetch, true)
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
