module OregonDigital
  module RdfProperties

    attr_accessor :properties

    def property(name, opts={}, &block)
      self.properties ||= {}.with_indifferent_access
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

  end
end
