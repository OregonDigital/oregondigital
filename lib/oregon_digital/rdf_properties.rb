module OregonDigital
  module RdfProperties

    attr_accessor :properties
    def property(name, opts={}, &block)
      self.properties ||= {}.with_indifferent_access
      config = ActiveFedora::Rdf::NodeConfig.new(name, opts[:predicate], :class_name => opts[:class_name]).tap do |config|
        config.with_index(&block) if block_given?
      end
      behaviors = config.behaviors.flatten if config.behaviors and not config.behaviors.empty?
      persistence = opts[:persistence]
      persistence ||= :parent
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
    # Mapper is for backwards compatibility.
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
