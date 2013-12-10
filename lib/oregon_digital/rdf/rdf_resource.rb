module OregonDigital::RDF
  class RdfResource < RDF::Graph
    extend RdfConfigurable
    extend RdfProperties

    def self.from_uri(uri,vals=nil)
      new(uri, vals)
    end

    # You can pass in only a parent with:
    #     RdfResource.new(nil, parent)
    def initialize(*args, &block)
      resource_uri = args.shift unless args.first.is_a?(Hash)
      parent = args.shift unless args.first.is_a?(Hash)
      set_subject!(resource_uri) if resource_uri
      super(*args, &block)
      reload(parent)
    end

    def rdf_subject
      @rdf_subject ||= RDF::Node.new
    end

    def node?
      return true if rdf_subject.kind_of? RDF::Node
      false
    end

    def base_uri
      self.class.base_uri
    end

    def type
      @type ||= self.class.type
    end

    def type=(type)
      raise "Type must be an RDF::URI" unless type.respond_to? :to_uri
      @type = type.to_uri
      self.update(rdf_subject, RDF::RDFS.type, type)
    end

    def rdf_label
      values = get_values(self.class.rdf_label)
      values = rdf_subject.to_s unless node? if values.empty?
      return values
    end
    alias_method :solrize, :rdf_label

    def persist!(parent=nil)
      repo = parent
      repo = RdfRepositories.repositories[self.class.repository] unless self.class.repository == :parent
      raise "failed when trying to persist to non-existant repository or parent resource" unless repo
      each_statement do |s, p, o|
        repo.delete [s, p, nil]
      end
      repo << self
      @persisted = true
    end

    def persisted?
      @persisted ||= false
    end

    def reload(parent=nil)
      repo = RdfRepositories.repositories[self.class.repository]
      if self.class.repository == :parent
        return false if parent.nil?
        repo = parent
      end
      self << repo.query(:subject => rdf_subject)
      # need to query differently for blank nodes?
      # Is there a solution which deals with both cases without iterating through potentially large repositories?
      if rdf_subject.node?
        repo.each_statement do |s|
          self << s if s.subject == rdf_subject
        end
      end
      unless empty?
        persisted = true
        type = type if type.kind_of? RDF::URI
      end
      true
    end

    def set_value(*args)
      # Add support for legacy 3-parameter syntax
      if args.length > 3 || args.length < 2
        raise ArgumentError("wrong number of arguments (#{args.length} for 2-3)")
      end
      if args.length == 3
        rdf_subject = args.shift
        rdf_subject = RDF::URI.new(rdf_subject.to_s) unless rdf_subject.kind_of? RDF::Resource
      else
        rdf_subject = self.rdf_subject
      end
      property = args.first
      values = args.last

      values = Array.wrap(values)
      predicate = predicate_for_property(property)
      delete([rdf_subject, predicate, nil])
      values.each do |val|
        val = RDF::Literal(val) if val.kind_of? String
        val = val.resource if val.respond_to?(:resource)
        #warn("Warning: #{val.to_s} is not of class #{property_class}.") unless val.kind_of? property_class or property_class == nil
        if val.kind_of? RdfResource
          add_child_node(property, val)
          next
        end
        val = val.to_uri if val.respond_to? :to_uri
        raise 'value must be an RDF URI, Node, Literal, or a plain string' unless
            val.kind_of? RDF::Resource or val.kind_of? RDF::Literal
        insert [rdf_subject, predicate, val]
      end
    end

    def get_values(*args)
      raise ArgumentError("wrong number of arguments (#{args.length} for 1-2)") if args.length < 1 || args.length > 2
      property = args.last
      if args.length > 1
        rdf_subject = args.first
      else
        rdf_subject = self.rdf_subject
      end
      values = []
      predicate = predicate_for_property(property)
      # Again, why do we need a special query for nodes?
      if node?
        each_statement do |statement|
          value = statement.object if statement.subject == rdf_subject and statement.predicate == predicate
          value = value.to_s if value.kind_of? RDF::Literal
          value = make_node(property, value) if value.kind_of? RDF::Resource
          values << value unless value.nil?
        end
        return values
      end
      query(:subject => rdf_subject, :predicate => predicate).each_statement do |statement|
        value = statement.object
        value = value.to_s if value.kind_of? RDF::Literal
        value = make_node(property, value) if value.kind_of? RDF::Resource
        values << value unless value.nil?
      end
      values
    end

    def set_subject!(uri_or_str)
      raise "Refusing update URI when one is already assigned!" unless node?
      # Refusing set uri to an empty string.
      return false if uri_or_str.nil? or uri_or_str.to_s.empty?
      # raise "Refusing update URI! This object is persisted to a datastream." if persisted?
      statements = query(:subject => rdf_subject)
      if uri_or_str.respond_to? :to_uri
        @rdf_subject = uri_or_str.to_uri
      elsif uri_or_str.to_s.start_with? '_:'
        @rdf_subject = RDF::Node(uri_or_str.to_s[2..-1])
      elsif base_uri
        separator = self.base_uri.to_s[-1,1] =~ /(\/|#)/ ? '' : '/'
        @rdf_subject = RDF::URI.intern(self.base_uri.to_s + separator + uri_or_str.to_s)
      elsif
        @rdf_subject = RDF::URI(uri_or_str)
      end

      unless empty?
        statements.each_statement do |statement|
          delete(statement)
          self << RDF::Statement.new(rdf_subject, statement.predicate, statement.object)
        end
      end
    end

    private

    def properties
      self.singleton_class.properties
    end

    def predicate_for_property(property)
      return properties[property][:predicate] unless property.kind_of? RDF::URI
      return property
    end

    def property_for_predicate(predicate)
      properties.each do |property, values|
        return property if values[:predicate] == predicate
      end
      return nil
    end

    def class_for_property(property)
      klass = properties[property][:class_name] if properties.include? property
      klass ||= OregonDigital::RDF::RdfResource
      klass
    end

    def add_child_node(property, resource)
      insert [rdf_subject, predicate_for_property(property), resource.rdf_subject]
      resource.persist!(self) if resource.class.repository == :parent
    end

    def node_cache
      @node_cache ||= {}
    end

    def make_node(property, value)
      klass = class_for_property(property)
      return node_cache[value] if node_cache[value]
      node = klass.from_uri(value,self)
      node_cache[value] = node
      return node
    end
  end
end
