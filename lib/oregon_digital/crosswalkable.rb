
module OregonDigital
  module Crosswalkable
    # TODO: make this work for non RDFDatastreams
    # TODO: make this work for RELS-EXT Datastreams
    def crosswalk_fields
      @crosswalk_fields ||= []
    end

    def content
      crosswalk_fields.each do |f|
        self.send(f)
      end
      super
    end

    def crosswalk(*args)
      args = args.first if args.respond_to? :first
      raise "crosswalk must specify an element as :field argument" unless args.kind_of?(Hash) && args.has_key?(:field)
      raise "crosswalk for '#{args[:field]}' must specify an element as :to argument" unless args.kind_of?(Hash) && args.has_key?(:to)
      raise "crosswalk for '#{args[:field]}' must specify a datastream as :in argument" unless args.kind_of?(Hash) && args.has_key?(:in)
      parent = digital_object
      field = args.delete(:field).to_sym
      element = args.delete(:to).to_sym
      ds = args.delete(:in)
      raise "#{parent.pid} does not have a datastream '#{ds.inspect}'" unless parent.datastreams.has_key? ds.to_s
      if parent.datastreams[ds.to_s].class.respond_to?(:fields)
        raise "datastream model '#{self.class}' does not define property '#{field.inspect}'" unless self.class.fields.include? field
        raise "datastream model '#{parent.datastreams[ds.to_s].class}' does not define property '#{element.inspect}'" unless parent.datastreams[ds.to_s].class.fields.include? element
      end

      crosswalk_fields << field
      target_datastream = parent.datastreams[ds.to_s]
      source_accessor = OregonDigital::CrosswalkAccessors::GenericAccessor.new(self,parent)
      target_accessor = OregonDigital::CrosswalkAccessors::GenericAccessor.new(target_datastream,parent)
      # TODO: Find a better way to do this.
      if target_datastream.kind_of?(ActiveFedora::RelsExtDatastream)
        target_accessor = OregonDigital::CrosswalkAccessors::RelsExtAccessor.new(target_datastream,parent)
      end
      define_singleton_method(field.to_s) do
        source_accessor.set_value(field.to_s, target_accessor.get_value(element))
        target_accessor.get_value(element.to_s)
      end
      singleton_class.class_eval do
        alias_method("#{field.to_s}_without_crosswalk=","#{field.to_s}=") if method_defined?("#{field.to_s}=")
      end
      define_singleton_method("#{field.to_s}=") do |v|
        if self.respond_to?("#{field.to_s}_without_crosswalk=")
          self.send("#{field.to_s}_without_crosswalk=",v)
        else
          self.send(:method_missing, "#{field.to_s}=",v)
        end
        target_accessor.set_value(element.to_s, v)
      end
    end
  end
end