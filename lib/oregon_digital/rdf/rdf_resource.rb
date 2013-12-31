module OregonDigital::RDF
  ##
  # Defines a generic RdfResource as an RDF::Graph with property
  # configuration, accessors, and some other methods for managing
  # "resources" as discrete subgraphs which can be managed by a Hydra
  # datastream model.
  #
  # Resources can be instances of RdfResource directly, but more
  # often they will be instances of subclasses with registered
  # properties and configuration. e.g.
  #
  #    class License < RdfResource
  #      configure :repository => :default
  #      property :title, :predicate => RDF::DC.title, :class_name => RDF::Literal do |index|
  #        index.as :displayable, :facetable
  #      end
  #    end
  class RdfResource < RDF::Graph
    extend RdfConfigurable
    extend RdfProperties
    attr_accessor :parent

    ##
    # Adapter for a consistent interface for creating a new node from a URI.
    # Similar functionality should exist in all objects which can become a node.
    def self.from_uri(uri,vals=nil)
      new(uri, vals)
    end

    ##
    # Initialize an instance of this resource class. Defaults to a
    # blank node subject. In addition to RDF::Graph parameters, you
    # can pass in a URI and/or a parent to build a resource from a
    # existing data.
    #
    # You can pass in only a parent with:
    #    RdfResource.new(nil, parent)
    #
    # @see RDF::Graph
    def initialize(*args, &block)
      resource_uri = args.shift unless args.first.is_a?(Hash)
      self.parent = args.shift unless args.first.is_a?(Hash)
      set_subject!(resource_uri) if resource_uri
      super(*args, &block)
      reload
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
      raise "Type must be an RDF::URI" unless type.kind_of? RDF::URI
      @type = type
      self.update(RDF::Statement.new(rdf_subject, RDF.type, type))
    end

    ##
    # Look for labels in various default fields if no rdf_label is set
    def rdf_label
      return get_values(self.class.rdf_label) if self.class.rdf_label
      values = get_values(RDF::SKOS.prefLabel)
      values = get_values(RDF::DC.title) if values.empty?
      values = get_values(RDF::RDFS.label) if values.empty?
      values = get_values(RDF::SKOS.altLabel) if values.empty?
      values = [rdf_subject.to_s] unless node? if values.empty?
      return values
    end
    alias_method :solrize, :rdf_label

    ##
    # Load data from URI
    # @TODO: use graph name context for provenance
    def fetch
      load(rdf_subject)
      self
    end

    def persist!
      raise "failed when trying to persist to non-existant repository or parent resource" unless repository
      each_statement do |s, p, o|
        repository.delete [s, p, nil]
      end
      repository << self
      @persisted = true
    end

    def persisted?
      @persisted ||= false
    end

    ##
    # Repopulates the graph from the repository or parent resource.
    def reload
      @node_cache = {}
      if self.class.repository == :parent
        return false if parent.nil?
      end
      self << repository.query(:subject => rdf_subject)
      # need to query differently for blank nodes?
      # Is there a solution which deals with both cases without iterating through potentially large repositories?
      if rdf_subject.node?
        repository.each_statement do |s|
          self << s if s.subject == rdf_subject
        end
      end
      unless empty?
        @persisted = true
      end
      self.type = type if type.kind_of? RDF::URI
      true
    end

    ##
    # Adds or updates a property with supplied values.
    #
    # Handles two argument patterns. The recommended pattern is:
    #    set_value(property, values)
    #
    # For backwards compatibility, there is support for explicitly
    # passing the rdf_subject to be used in the statement:
    #    set_value(uri, property, values)
    #
    # @note This method will delete existing statements with the correct subject and predicate from the graph
    def set_value(*args)
      # Add support for legacy 3-parameter syntax
      if args.length > 3 || args.length < 2
        raise ArgumentError("wrong number of arguments (#{args.length} for 2-3)")
      end
      if args.length == 3
        rdf_subject = args.shift
        rdf_subject = RDF::URI.new(rdf_subject.to_s) unless rdf_subject.kind_of? RDF::Value
      else
        rdf_subject = self.rdf_subject
      end
      property = args.first
      values = args.last

      values = Array.wrap(values)
      predicate = predicate_for_property(property)
      delete([rdf_subject, predicate, nil])
      old_value = self.get_values(property)
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
            val.kind_of? RDF::Value or val.kind_of? RDF::Literal
        insert [rdf_subject, predicate, val]
      end
    end

    ##
    # Returns an array of values belonging to the property
    # requested. Elements in the array may be strings or RdfResource
    # objects.
    #
    # Handles two argument patterns. The recommended pattern is:
    #    get_values(property)
    #
    # For backwards compatibility, there is support for explicitly
    # passing the rdf_subject to be used in th statement:
    #    get_values(uri, property)
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
          value = make_node(property, value) if value.kind_of? RDF::Value
          values << value unless value.nil?
        end
        return values
      end
      query(:subject => rdf_subject, :predicate => predicate).each_statement do |statement|
        value = statement.object
        value = value.to_s if value.kind_of? RDF::Literal
        value = make_node(property, value) if value.kind_of? RDF::Value
        values << value unless value.nil?
      end
      values
    end

    ##
    # Set a new rdf_subject for the resource.
    #
    # This raises an error if the current subject is not a blank node,
    # and returns false if it can't figure out how to make a URI from
    # the param. Otherwise it creates a URI for the resource and
    # rebuilds the graph with the updated URI.
    #
    # Will try to build a uri as an extension of the class's base_uri
    # if appropriate.
    #
    # @param [#to_uri, #to_s] uri_or_str the uri or string to use
    def set_subject!(uri_or_str)
      raise "Refusing update URI when one is already assigned!" unless node?
      # Refusing set uri to an empty string.
      return false if uri_or_str.nil? or uri_or_str.to_s.empty?
      # raise "Refusing update URI! This object is persisted to a datastream." if persisted?
      old_subject = rdf_subject
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
        each_statement do |statement|
          if statement.subject == old_subject
            delete(statement)
            self << RDF::Statement.new(rdf_subject, statement.predicate, statement.object)
          elsif statement.object == old_subject
            delete(statement)
            self << RDF::Statement.new(statement.subject, statement.predicate, rdf_subject)
          end
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
      resource.parent = self
      resource.persist! if resource.class.repository == :parent
    end

    ##
    # Return the repository (or parent) that this resource should
    # write to when persisting.
    def repository
      @repository ||= begin
        if self.class.repository == :parent
          parent
        else
          OregonDigital::RDF::RdfRepositories.repositories[self.class.repository]
        end
      end
    end

    def node_cache
      @node_cache ||= {}
    end

    ##
    # Build a child resource or return it from this object's cache
    #
    # Builds the resource from the class_name specified for the
    # property.
    def make_node(property, value)
      klass = class_for_property(property)
      return node_cache[value] if node_cache[value]
      node = klass.from_uri(value,self)
      node_cache[value] = node
      return node
    end

  end
end
