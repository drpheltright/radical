module Radical
  module Typed
    class Array < Array
      def self.[](type)
        Class.new(self).tap do |array_class|
          array_class.set_type(type)
        end
      end

      def self.set_type(type)
        @type = type
      end

      def self.type
        @type
      end

      def self.coerce(hash)
        new(hash)
      end

      def initialize(array)
        super(array.map { |value| Coercer.coerce(self.class.type, value) })
      end
    end
  end
end
