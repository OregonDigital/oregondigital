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
        first_file = ingester.bag.bag_files.first
        unless first_file.nil?
          mime = FileMagic.new(FileMagic::MAGIC_MIME).file(ingester.bag.bag_files.first).split(';')[0]
        end

j       # Get class from mime pattern
        # TODO: extract this logic to GenericAsset (or elsewhere?)
        for pattern, asset_class in ASSET_CLASS_LOOKUP
          if pattern === mime
            klass = asset_class
          end
        end

        puts "Ingesting #{ingester.bag.bag_dir}"
        if bag_exists?(ingester.bag)
          puts "Content already exists - #{ingester.bag.bag_dir} - skipping."
          return
        end
        ingester.model_name = klass ? klass.to_s : self.to_s
        asset = ingester.ingest
        update_rdf_subject(asset)
        asset.content.mimeType = mime
        # Overwrite existing format with the actual content format
        asset.format = ::RDF::URI("http://purl.org/NET/mediatypes/#{asset.content.mimeType}") if mime
        sleep(2)
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

    def bag_exists?(bag)
      ntriples = bag.tag_files.find{|x| x.include? "descMetadata.nt"}
      graph = ::RDF::Graph.load(ntriples)
      replaces_url = graph.query([nil, ::RDF::DC.replaces, nil]).map{|x| x.object.to_s}.first
      item_exists?(replaces_url)
    end

    def item_exists?(replaces_url)
      documents = ActiveFedora::SolrService.query("desc_metadata__replacesUrl_ssim:#{RSolr.escape(replaces_url)}", :rows => 10000)
      !documents.blank?
    end

    def title_exists?(title, identifier)
      documents = ActiveFedora::SolrService.query("desc_metadata__title_teim:#{RSolr.escape(title)}")
      !documents.find do |x|
        x["desc_metadata__title_ssm"].include?(title) && identifier == x["desc_metadata__identifier_ssm"]
      end.nil?
    end

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
