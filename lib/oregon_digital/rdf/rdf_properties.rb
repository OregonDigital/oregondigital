module OregonDigital::RDF
  ##
  # Implements property configuration common to RdfResource and
  # RdfResourceDatastream.  It does its work at the class level, and
  # is meant to be extended.
  #
  # Define properties at the class level with:
  #
  #    property :title, :predicate => RDF::DC.title, :class_name => ResourceClass
  #
  # or with the 'old' ActiveFedora::RDFDatastream style:
  #
  #    map_predicates do |map|
  #      map.title(:in => RDF::DC)
  #    end
  #
  # You can pass a block to either to set index behavior.
  module RdfProperties
    attr_accessor :properties

    ##
    # Registers properties for RdfResource like classes
    # @param [Symbol]  name of the property (and its accessor methods)
    # @param [Hash]  opts for this property, must include a :predicate
    # @yield [index] index sets solr behaviors for the property
    def property(name, opts={}, &block)
      config = ActiveFedora::Rdf::NodeConfig.new(name, opts[:predicate], :class_name => opts[:class_name]).tap do |config|
        config.with_index(&block) if block_given?
      end
      behaviors = config.behaviors.flatten if config.behaviors and not config.behaviors.empty?
      self.properties[name] = {
        :behaviors => behaviors,
        :type => config.type,
        :class_name => config.class_name,
        :predicate => config.predicate,
        :term => config.term
      }
      register_property(name)
    end

    def properties
      @properties ||= if superclass.respond_to? :properties
        superclass.properties.dup
      else
        {}.with_indifferent_access
      end
    end

    private

    ##
    # Private method for creating accessors for a given property.
    # If used on an ActiveFedora::Datastream it will create accessors which use the datastream's resource.
    # @param [#to_s] name Name of the accessor to be created, get/set_value is called on the resource using this.
    def register_property(name)
      parent = Proc.new{self}
      parent = Proc.new{resource} if self < ActiveFedora::Datastream
      define_method "#{name}=" do |*args|
        instance_eval(&parent).set_value(name.to_sym, *args)
      end
      define_method name do
        instance_eval(&parent).get_values(name.to_sym)
      end
    end

    public
    # Mapper is for backwards compatibility with AF::RDFDatastream
    class Mapper
      attr_accessor :parent
      def initialize(parent)
        @parent = parent
      end
      def method_missing(name, *args, &block)
        properties = args.first || {}
        vocab = properties.delete(:in)
        to = properties.delete(:to) || name
        predicate = vocab.send(to)
        parent.property(name, properties.merge(:predicate => predicate), &block)
      end
    end
    def map_predicates
      mapper = Mapper.new(self)
      yield(mapper)
    end

  end
end
