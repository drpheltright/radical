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
        subclass.path = self.path
        subclass.type = self.type
        replace_registered_route(self, subclass)
      end
    end

    def handle(request)
      method, *path = request
      return unless respond_to?(method)
      route_method(method).handle(path)
    end

    private

    def route_method(method)
      self.class.const_get(method.capitalize).new(self)
    end

    class RouteMethod < Struct.new(:route)
      private

      def matches_path?(path)
        route.class.path.each_with_index do |path_part, i|
          return false unless path_part.is_a?(Arg) or path_part == path[i]
        end

        true
      end

      def parse_path_parts(path)
        path.each_with_index.map do |path_part, i|
          if route.class.path[i].is_a?(Arg)
            route.class.path[i].coerce(path_part.to_s)
          else
            path_part
          end
        end
      end

      def extract_path_args(path)
        path.each_with_index.reduce([]) do |args, (path_part, i)|
          if route.class.path[i].is_a?(Arg)
            args << route.class.path[i].coerce(path_part.to_s)
          else
            args
          end
        end
      end
    end

    class Get < RouteMethod
      def handle(path)
        if matches_path?(path)
          {}.tap do |response|
            *path_parts, last_path_part = parse_path_parts(path)

            last_nested_object = path_parts.reduce(response) do |response, path|
              response[path] = {}
            end

            last_nested_object[last_path_part] = coerce(route.get(*extract_path_args(path)))
          end
        end
      end

      private

      def coerce(value)
        Typed::Coercer.coerce(route.class.type, value)
      end
    end

    class Set < RouteMethod
      def handle(path)
        *path, value = path

        if matches_path?(path)
          args = extract_path_args(path) << value
          route.set(*args)
          route.handle([:get].concat(path))
        end
      end
    end
  end
end
