class Datastream::RdfResourceDatastream < ActiveFedora::Datastream
  include Solrizer::Common
  extend OregonDigital::RDF::RdfProperties

  before_save do
    if content.blank?
      logger.warn "Cowardly refusing to save a datastream with empty content: #{self.inspect}"
      false
    end
  end

  def initialize(*args, &block)
    ds_props = self.class.properties
    @resource_class = Class.new(OregonDigital::RDF::ObjectResource) do
      # properties = ds_props
      ds_props.each do |field, args|
        behaviors = args[:behaviors]
        type = args[:type]
        property field, args do |index|
          index.as behaviors
          index.type type
        end
      end
    end
    super(*args, &block)
  end

  def metadata?
    true
  end

  def prefix(name)
    name = name.to_s unless name.is_a? String
    pre = dsid.underscore
    return "#{pre}__#{name}".to_sym
  end

  def content
    serialize
  end

  def content=(content)
    resource.clear!
    resource << RDF::Reader.for(serialization_format).new(content)
    content
  end

  def content_changed?
    @content = serialize
    super
  end

  def graph
    resource
  end

  def resource
    @resource ||= begin
      r = @resource_class.new
      r << RDF::Reader.for(serialization_format).new(datastream_content) if datastream_content
      r
    end
  end

  def term_values(*values)
    current_value = nil
    values.each do |value|
      current_value = self.send(value)
    end
    return current_value
  end

  def update_indexed_attributes(hash)
    hash.each do |fields, value|
      fields.each do |field|
        self.send("#{field}=", value)
      end
    end
  end

  def rdf_subject
    resource.rdf_subject
  end

  def serialize
    resource.set_subject!(pid) if pid and rdf_subject.node?
    resource.dump serialization_format
  end

  def deserialize(data=nil)
    return RDF::Graph.new if new? and data.nil?
    data ||= datstream_content
    RDF::Graph.new << RDF::Reader.for(serialization_format).new(content)
  end

  def serialization_format
    raise "you must override the `serialization_format' method in a subclass"
  end

  def to_solr(solr_doc = Hash.new) # :nodoc:
    fields.each do |field_key, field_info|
      values = resource.get_values(field_key)
      if values
        Array(values).each do |val|
          val = val.to_s if val.kind_of? RDF::URI
          val = val.solrize if val.kind_of? OregonDigital::RDF::RdfResource
          self.class.create_and_insert_terms(prefix(field_key), val, field_info[:behaviors], solr_doc)
        end
      end
    end
    solr_doc
  end

  def fields
    field_map = {}.with_indifferent_access

    self.class.properties.each do |name, config|
      type = config[:type]
      behaviors = config[:behaviors]
      next unless type and behaviors
      resource.query(:subject => rdf_subject, :predicate => config[:predicate]).each_statement do |statement|
        field_map[name] ||= {:values => [], :type => type, :behaviors => behaviors}
        field_map[name][:values] << statement.object.to_s
      end
    end
  end

end
