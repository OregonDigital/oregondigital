module OregonDigital
  module BagIngestible
    def bulk_ingest_bags(dir)
      assets = []
      Hybag::BulkIngester.new(dir).each do |ingester|
        @fail_ingest = 0
        ingest_bag(ingester, assets)
      end
      assets
    end

    def ingest_bag(ingester, assets)
      begin
        sleep(2)
        first_file = ingester.bag.bag_files.first
        unless first_file.nil?
          mime = FileMagic.new(FileMagic::MAGIC_MIME).file(ingester.bag.bag_files.first).split(';')[0]
        end

        # Get class from mime pattern
        # TODO: extract this logic to GenericAsset (or elsewhere?)
        for pattern, asset_class in ASSET_CLASS_LOOKUP
          if pattern === mime
            klass = asset_class
          end
        end

        puts "Ingesting #{ingester.bag.bag_dir}"
        ingester.model_name = klass ? klass.to_s : self.to_s
        asset = ingester.ingest
        update_rdf_subject(asset)
        asset.content.mimeType = mime
        # Overwrite existing format with the actual content format
        asset.format = ::RDF::URI("http://purl.org/NET/mediatypes/#{asset.content.mimeType}") if mime
        asset.save
      rescue Rubydora::FedoraInvalidRequest
        @fail_ingest += 1
        if @fail_ingest >= 3
          raise "Failed to ingest asset 3 times."
          return
        end
        puts "Failed to ingest asset #{@fail_ingest} times. Retrying."
        ingest_bag(Hybag::Ingester.new(BagIt::Bag.new(ingester.bag.bag_dir)), assets)
      end
      assets << asset
    end

    private

    def update_rdf_subject(asset)
      asset.descMetadata.resource.each_statement do |s|
        if s.subject.to_s.start_with? 'http://example.org'
          asset.descMetadata.resource.delete s
          asset.descMetadata.resource << ::RDF::Statement.new(asset.descMetadata.rdf_subject, s.predicate, s.object)
        end
      end
    end
  end
end
