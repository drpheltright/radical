require 'JSON'
require 'rack'

module Radical
  class Application
    attr_writer :router

    def call(env)
      request = Rack::Request.new(env)
      routes = parse_routes(request[:route])

      if routes.empty?
        response(400, error: 'No routes provided.')
      else
        match_routes(routes)
      end
    end

    private

    def router
      @router ||= Router.new
    end

    def parse_routes(routes)
      return [] unless routes.respond_to?(:map)

      routes.map do |(route, value)|
        if value.nil?
          [:get].concat(route.split('.').map(&:to_sym))
        else
          [:set].concat(route.split('.').map(&:to_sym)).push(value)
        end
      end
    end

    def match_routes(routes)
      response(200, router.route(routes))
    rescue Router::RequestUnmatchedError => e
      response(404, error: 'No routes matched request.')
    end

    def response(status, data)
      Rack::Response.new([JSON.dump(data)], status, { 'Content-Type' => 'application/json' })
    end
  end
end
