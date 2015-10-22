module Radical
  class Route
    class MethodUndefinedError < RuntimeError; end

    def self.registered_routes
      @routes ||= []
    end

    def self.replace_registered_route(original, replacement)
      index = Route.registered_routes.find_index { |route_class| route_class == original }
      Route.registered_routes[index] = replacement
    end

    def self.[](*path)
      Class.new(self).tap do |route_class|
        route_class.type = path.pop
        route_class.path = path
        Route.registered_routes << route_class
      end
    end

    def self.path=(path); @path = path; end
    def self.path; @path; end

    def self.type=(type); @type = type; end
    def self.type; @type; end

    def self.define(&block)
      class_eval(&block)
      self
    end

    def self.inherited(subclass)
      if self != Route
        replace_registered_route(self, subclass)
      end
    end

    def handle(request)
      method, *path = request
      call(method, path)
    end

    private

    def matches_path?(path)
      self.class.path == path
    end

    def call(method, path)
      return nil unless respond_to?(method)

      case method
      when :set
        *path, value = path

        if matches_path?(path)
          set(value)
          call(:get, path)
        end
      when :get
        if matches_path?(path)
          { path.first => Typed::Coercer.coerce(self.class.type, get) }
        end
      end
    end
  end
end
