module OregonDigital
  class RdfResource < RDF::Graph
    extend RdfConfigurable

    def initialize(*args, &block)
      resource_uri = args.shift unless args.first.is_a?(Hash)
      set_subject!(resource_uri) if resource_uri
      super(*args, &block)
    end

    def subject
      @subject ||= RDF::Node.new
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
      self.set_value(RDF::RDFS.type, type)
    end

    def rdf_label
      get_values(self.class.rdf_label)
    end

    def set_value(property, values)
      values = [values] if values.kind_of? RDF::Graph
      values = Array(values)
      property_class = class_for_property(property)
      property = predicate_for_property(property) unless property.kind_of? RDF::URI
      delete([subject, property, nil])
      values.each do |val|
        val = RDF::Literal(val) if val.kind_of? String
        # warn("Warning: #{val.to_s} is not of class #{property_class}.") unless val.kind_of? property_class or property_class == nil
        if val.kind_of? RdfResource
          add_node(property, val)
          next
        end
        val = val.to_uri if val.respond_to? :to_uri
        raise 'value must be an RDF URI, Node, Literal, or a plain string' unless
            val.kind_of? RDF::Resource or val.kind_of? RDF::Literal
        insert [subject, property, val]
      end
    end

    def get_values(property)
      values = []
      property = predicate_for_property(property) unless property.kind_of? RDF::URI
      query(:subject => subject, :predicate => property).each_statement do |statement|
        value = statement.object
        value = value.to_s if value.kind_of? RDF::Literal
        values << value
      end
      values
    end

    def set_subject!(uri_or_str)
      raise "Refusing update URI when one is already assigned!" unless subject.node?
      statements = query(:subject => subject)
      if uri_or_str.respond_to? :to_uri
        @subject = uri_or_str.to_uri
      elsif base_uri
        separator = self.base_uri.to_s[-1,1] =~ /(\/|#)/ ? '' : '/'
        @subject = RDF::URI.intern(self.base_uri.to_s + separator + uri_or_str.to_s)
      else
        @subject = RDF::URI(uri_or_str)
      end

      unless empty?
        statements.each_statement do |statement|
          delete(statement)
          self << RDF::Statement.new(subject, statement.predicate, statement.object)
        end
      end
    end

    private

    def predicate_for_property(property)
      self.class.properties[property][:predicate]
    end

    def class_for_property(property)
      self.class.properties[property][:class_name] if self.class.properties.include? property
    end

    def add_node(property, resource)
      insert [subject, predicate_for_property(property), resource.subject]
    end

  end
end
