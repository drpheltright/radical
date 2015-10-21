module Radical
  module Typed
    class Hash < Hash
      class UndefinedKeyError < RuntimeError; end

      def self.[](schema)
        Class.new(self).tap do |hash_class|
          hash_class.set_schema(schema)
        end
      end

      def self.set_schema(schema)
        @schema = schema
      end

      def self.schema
        @schema
      end

      def self.coerce(hash)
        new(hash)
      end

      def initialize(hash)
        hash.reduce(self) do |coerced_hash, (key, value)|
          coerced_hash.merge!(key => Coercer.coerce(type_for_key(key), value))
        end
      end

      private

      def type_for_key(key)
        self.class.schema[key] or
          raise UndefinedKeyError.new("Undefined key: #{self.class.name}[:#{key}]")
      end
    end
  end
end
