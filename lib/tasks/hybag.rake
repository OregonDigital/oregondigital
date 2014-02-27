
require 'hybag'

desc 'Ingest content from Bags'

task :bag_ingest, [:directory, :collection, :model] => [:environment] do |t, args|
  raise "Please include a directory, collection id, and model: `rake bag_ingest[./bags,bag-collection,Model]`" if args[:directory].nil? or args[:collection].nil? or args[:model].nil?
  collection = GenericCollection.find(:pid => "oregondigital:#{args[:collection]}").first
  if collection.nil?
    collection = GenericCollection.new(:pid => "oregondigital:#{args[:collection]}")
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
    object.descMetadata.set = collection
    object.save
    print '.'
  end
end
