module OregonDigital
  module CrosswalkAccessors
    class RelsExtAccessor < GenericAccessor
      def get_value(field)
        RelsProxy.new(datastream.model.relationships(field.to_sym), self, field)
      end
      def set_value(field, value)
        datastream.model.clear_relationship(field.to_sym)
        value = Array.wrap(value)
        value.each do |v|
          datastream.model.add_relationship(field.to_sym, v)
        end
      end
    end
    class RelsProxy
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