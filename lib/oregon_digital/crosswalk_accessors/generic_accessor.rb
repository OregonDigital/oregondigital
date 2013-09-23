module OregonDigital
  module CrosswalkAccessors
    class GenericAccessor
      attr_accessor :datastream, :parent
      def initialize(datastream,parent=nil)
        self.datastream = datastream
        self.parent = parent
      end
      def get_value(field)
        datastream.send(field.to_s)
      end

      def set_value(field, value)
        datastream.send(:method_missing, "#{field.to_s}=",value)
      end
    end
  end
end