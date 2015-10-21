module Radical
  module Typed
    class CoercionError < TypeError
      def initialize(type, value)
        super("Could not convert #{value.class}(#{value}) to #{type}")
      end
    end
  end
end
