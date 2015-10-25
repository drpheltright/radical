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
      handle_method_and_path(method, path)
    end

    private

    def matches_path?(path)
      self.class.path.each_with_index do |path_part, i|
        return false unless path_part.is_a?(Arg) or path_part == path[i]
      end

      true
    end

    def path_args(path)
      path.each_with_index.reduce([]) do |args, (path_part, i)|
        if self.class.path[i].is_a?(Arg)
          args << path_part
        else
          args
        end
      end
    end

    def handle_method_and_path(method, path)
      return nil unless respond_to?(method)

      case method
      when :get
        if matches_path?(path)
          {}.tap do |response|
            *path_parts, last_path_part = path.dup

            last_nested_object = path_parts.reduce(response) do |response, path|
              response[path] = {}
            end

            last_nested_object[last_path_part] = Typed::Coercer.coerce(self.class.type, get(*path_args(path)))
          end
        end
      when :set
        *path, value = path

        if matches_path?(path)
          args = path_args(path) << value
          set(*args)
          handle_method_and_path(:get, path)
        end
      end
    end
  end
end
