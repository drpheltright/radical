module Radical
  class Route
    def self.registered_routes
      @routes ||= []
    end

    def self.replace_registered_route(original, replacement)
      index = Route.registered_routes.find_index { |route_class| route_class == original }
      Route.registered_routes[index] = replacement
    end

    def self.[](*args)
      Class.new(self).tap do |route_class|
        Route.registered_routes << route_class
      end
    end

    def self.define(&block)
      class_eval(&block)
      self
    end

    def self.inherited(subclass)
      if self != Route
        replace_registered_route(self, subclass)
      end
    end
  end
end
