module Radical
  module Typed
    class Coercer
      def self.coerce(type, value)
        if type.respond_to?(:coerce)
          type.coerce(value)
        else
          ruby_style_coerce(type, value)
        end
      rescue TypeError, ArgumentError
        raise CoercionError.new(type, value)
      end

      private

      def self.ruby_style_coerce(type, value)
        modules = type.name.split('::')
        method = modules.pop.to_sym

        mod = modules.reduce(Module) do |mod, next_mod|
          mod.const_get(next_mod)
        end

        mod.send(method, value)
      end
    end
  end
end
