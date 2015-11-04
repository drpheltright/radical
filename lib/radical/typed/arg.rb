module Radical
  module Typed
    class Arg < Struct.new(:name, :type)
      def self.[](arg)
        if arg.is_a?(::Hash)
          name, type = arg.first
          new(name, type)
        else
          new(name, String)
        end
      end

      def coerce(value)
        Coercer.coerce(type, value)
      end
    end
  end
end
