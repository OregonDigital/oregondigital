
require 'hybag'
require 'filemagic'

desc 'Ingest content from Bags'

task :bag_ingest, [:directory, :collection, :model] => :environment do |t, args|
  raise "Please include a directory, collection id, and model: `rake bag_ingest[./bags,bag-collection,Model]`" if args[:directory].nil? or args[:collection].nil? or args[:model].nil?
  collection = GenericCollection.find(:pid => "oregondigital:#{args[:collection]}").first
  if collection.nil?
    collection = GenericCollection.new(:pid => "oregondigital:#{args[:collection]}")
    collection.title = args[:collection]
    collection.review!
    collection.save
  end
  Hybag::BulkIngester.new(args[:directory]).each do |ingester|
    # TODO: determine model from content type!
    ingester.model_name = args[:model].capitalize
    object = ingester.ingest
    object.descMetadata.resource.each_statement do |s|
      if s.subject.to_s.start_with? 'http://example.org'
        object.descMetadata.resource.delete s
        object.descMetadata.resource << RDF::Statement.new(object.descMetadata.rdf_subject, s.predicate, s.object)
      end
    end
    # set the mime type to the actual type of the content datastream
    object.content.mimeType = FileMagic.new(FileMagic::MAGIC_MIME).file(ingester.bag.bag_files.first).split(';')[0]
    object.format = RDF::URI("https://w3id.org/spar/mediatype/#{object.content.mimeType}") unless object.format
    object.set = collection
    object.save
    print '.'
 end
end

task :review_collection, [:collection_slug] => [:environment] do |t, args|
  raise "Please include a collection identifer: `rake review_collection[braceros]`" if args[:collection_slug].nil?
  col = GenericCollection.find(:pid => "oregondigital:#{args[:collection_slug]}")
  col.memebers.each { |item| item.review! }
end
