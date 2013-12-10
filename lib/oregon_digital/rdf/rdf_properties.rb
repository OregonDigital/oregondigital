module OregonDigital::RDF
  module RdfProperties
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

    def register_property(name)
      parent = ''
      parent = 'resource.' if self < ActiveFedora::Datastream
      class_eval <<-eoruby, __FILE__, __LINE__ + 1
        def #{name}=(*args)
           #{parent}set_value(:#{name}, *args)
        end
        def #{name}
           #{parent}get_values(:#{name})
        end
      eoruby
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
