module OregonDigital
  module CrosswalkAccessors
    class OmAccessor < GenericAccessor
      def get_value(field)
        OmProxy.new(datastream.send(:term_values, *field), self, field)
      end
      def set_value(field, value)
        value = Array.wrap(value)
        datastream.send(:update_indexed_attributes, {field => value})
      end
    end
    class OmProxy
      attr_accessor :array, :accessor, :field
      delegate *(Array.public_instance_methods - [:__send__, :__id__, :class, :object_id] + [:as_json]), :to => :array
      def initialize(array, accessor, field)
        self.array = array
        self.accessor = accessor
        self.field = field
      end
      def << (value)
        array << value
        accessor.set_value(field, array)
      end
    end
  end
end
