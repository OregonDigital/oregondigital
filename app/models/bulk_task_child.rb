class BulkTaskChild < ActiveRecord::Base
  validates :target, :presence => true
  validate :ingested_status_valid

  belongs_to :bulk_task
  serialize :result
  delegate :pending?, :ingesting?, :ingested?, :reviewed?, :reviewing?, :errored?, :to => :status

  def status
    ActiveSupport::StringInquirer.new(attributes['status'])
  end

  def asset
    return unless ingested_pid
    @asset ||= ActiveFedora::Base.find(ingested_pid).adapt_to_cmodel
  end

  def queue_ingest!
    self.status = "ingesting"
    save
    Resque.enqueue(BulkIngest::IngestChild, self.id)
  end

  def ingest!
    if bulk_task.type == :bag
      bag_ingest!
    end
  end

  def queue_review!
    self.status = "reviewing"
    save
    Resque.enqueue(BulkIngest::ReviewChild, self.id)
  end

  def review!
    begin
      asset.review!
      self.status = "reviewed"
    rescue StandardError => e
      self.status = "errored"
      self.result = {}
      self.result[:result] = "Failed During Review"
      self.result[:error] = {}
      self.result[:error][:message] = e.message
      self.result[:error][:trace] = e.backtrace
    ensure
      save
    end
  end

  private

  def bag_ingest!
    begin
      ingester = Hybag::Ingester.new(bag)
      asset = build_bag_asset(ingester)
      asset.save!
      self.status = "ingested"
      self.ingested_pid = asset.pid
    rescue StandardError => e
      self.status = "errored"
      self.result ||= {}
      self.result[:result] = "Exception Thrown"
      self.result[:error] ||= {}
      self.result[:error][:message] = e.message
      self.result[:error][:trace] = e.backtrace
    ensure
      save
    end
    self
  end

  def build_bag_asset(ingester)
    return existing_asset if existing_asset
    ingester.model_name = bag_class.to_s
    asset = ingester.ingest
    (asset.content.mimeType = bag_mime) if bag_mime
    (asset.format = ::RDF::URI("http://purl.org/NET/mediatypes/#{asset.content.mimeType}")) if bag_mime
    update_rdf_subject(asset)
    asset
  end

  def update_rdf_subject(asset)
    asset.resource.each_statement do |s|
      if s.subject.to_s.start_with? 'http://example.org'
        asset.resource.delete s
        asset.resource << ::RDF::Statement.new(asset.resource.rdf_subject, s.predicate, s.object)
      end
    end
  end

  def existing_asset
    @existing_asset ||= begin
                          ntriples = bag.tag_files.find{|x| x.include? "descMetadata.nt"}
                          graph = ::RDF::Graph.load(ntriples)
                          replaces_url = graph.query([nil, ::RDF::DC.replaces, nil]).map{|x| x.object.to_s}.first
                          documents = ActiveFedora::SolrService.query("desc_metadata__replacesUrl_ssim:#{RSolr.escape(replaces_url)}", :rows => 10000)
                          ActiveFedora::Base.find(documents[0]["id"]).adapt_to_cmodel unless documents.blank?
                        end
  end


  def bag
    BagIt::Bag.new(target) if bulk_task.type == :bag
  end

  def bag_mime
    @bag_mime ||= begin 
                    mime = nil
                    first_file = bag.bag_files.find{|x| x.include?("content")}
                    unless first_file.nil?
                      mime = FileMagic.new(FileMagic::MAGIC_MIME).file(first_file).split(';')[0]
                    end
                    mime
                  end
  end

  def bag_class
    @bag_class ||= begin
                     bag_class = GenericAsset
                     # Get class from mime pattern
                     # TODO: extract this logic to GenericAsset (or elsewhere?)
                     for pattern, asset_class in ASSET_CLASS_LOOKUP
                       if pattern === bag_mime
                         bag_class = asset_class
                       end
                     end
                     bag_class
                   end
  end


  def ingested_status_valid
    if !ingested_pid.present? && ingested?
      errors.add(:status, "can not be ingested without an attached pid")
    end
  end
end
