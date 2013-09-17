
module OregonDigital
  module Crosswalkable
    # TODO: make this work for non RDFDatastreams
    # TODO: make this work for RELS-EXT Datastreams
    def crosswalk_fields
      @crosswalk_fields ||= []
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
      raise "datastream model '#{self.class}' does not define property '#{field.inspect}'" unless self.class.fields.include? field
      raise "datastream model '#{parent.datastreams[ds.to_s].class}' does not define property '#{element.inspect}'" unless parent.datastreams[ds.to_s].class.fields.include? element
      instance_eval do
        alias :uncrosswalked_content :content unless respond_to? :uncrosswalked_content
      end
      if crosswalk_fields == [] # so this only runs once
        self.metaclass.send(:define_method, "content") do
          crosswalk_fields.each do |f|
            self.send(f)
          end
          uncrosswalked_content
        end
      end

      crosswalk_fields << field

      self.metaclass.send(:define_method, field.to_s) do
        # TODO: make this work for non RDFDatastreams
        # TODO: better way to do this with alias old_#{field} #{field} ?
        self.send(:set_value, rdf_subject, field.to_sym, parent.datastreams[ds.to_s].send(element)) if self.kind_of? ActiveFedora::RDFDatastream
        parent.datastreams[ds.to_s].send(element)
      end

      self.metaclass.send(:define_method, "#{field.to_s}=") do |v|
        parent.datastreams[ds.to_s].send("#{element}=", v)
      end
    end

    def metaclass
      class << self; self; end
    end
  end
end
