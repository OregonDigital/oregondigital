class GenericAsset < ActiveFedora::Base
  include Hydra::AccessControls::Permissions
  include Hydra::ModelMethods
  include Hydra::Derivatives
  include Hybag::Baggable
  include OregonDigital::Workflow
  include OregonDigital::OAI::Concern
  include OregonDigital::DateSorting
  include ActiveFedora::Rdf::Identifiable
  extend OregonDigital::CsvBulkIngestible

  has_metadata :name => 'descMetadata', :type => Datastream::OregonRDF
  has_metadata :name => 'rightsMetadata', :type =>
    Datastream::RightsMetadata

  has_file_datastream name: 'content', type: Datastream::Content

  before_save :check_derivatives
  after_save :queue_derivatives
  attr_accessor :skip_queue
  after_save :queue_fetch
  after_save :check_cache


  def self.assign_pid(_)
    OregonDigital::IdService.mint
  end

  def self.destroyed
    where(Solrizer.solr_name("workflow_metadata__destroyed", :symbol) => "true")
  end

  has_attributes :format, :type, :location, :created, :description, :rights, :title, :modified, :date, :datastream => :descMetadata, :multiple => false
  has_attributes :identifier, :lcsubject, :set, :creator, :contributor, :institution, :datastream => :descMetadata, :multiple => true
  delegate :od_content, :to => :descMetadata, :allow_nil => true

  def compound?
    od_content_uris.length > 0
  end

  def od_content_uris
    resource.query([resource.rdf_subject, OregonDigital::Vocabularies::OREGONDIGITAL.contents, nil]).map{|x| x.object}
  end

  def compounded?
    compound_parent.present?
  end

  def compound_parent
    @compound_parent ||= ActiveFedora::Base.load_instance_from_solr(compound_parent_id) if compound_parent_id
  end

  private

  def compound_parent_id
    @compound_parent_id ||= ActiveFedora::SolrService.query("#{Solrizer.solr_name("desc_metadata__od_content", :symbol)}:#{RSolr.escape(resource.rdf_subject.to_s)}", :fl => "id", :rows => 1).map{|x| x["id"]}.first
  end

  def queue_fetch
    skip_queue ? self.skip_queue = nil : Resque.enqueue(FetchAllJob,pid)
  end

  def check_derivatives
    @needs_derivatives = (content.content_changed? && !content.content.blank?)
    true
  end

  def queue_derivatives
    ::Resque.enqueue(::CreateDerivativesJob,pid) if @needs_derivatives
  end

  def check_cache
    if compound?
      #expire myself
      ActionController::Base.new.expire_fragment("cpd/"+id)
      #expire the children
      od_content.each do |child|
        if child.respond_to? :id
          ActionController::Base.new.expire_fragment("cpd/"+ child.id)
        end
      end
    elsif compounded?
      #expire parent
      ActionController::Base.new.expire_fragment("cpd/" + compound_parent_id)
      #expire the children
      compound_parent.od_content.each do |child|
        if child.respond_to? :id
          ActionController::Base.new.expire_fragment("cpd/" + child.id)
        end
      end
    end
  end

end
