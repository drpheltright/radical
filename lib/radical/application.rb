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
        data = router.route(routes)

        if data.empty?
          response(404, error: 'No routes matched.')
        else
          response(200, data)
        end
      end
    end

    private

    def router
      @router ||= Router.new
    end

    def parse_routes(routes)
      return [] unless routes.respond_to?(:map)
      routes.map { |(route, _)| [:get].concat(route.split('.').map(&:to_sym)) }
    end

    def response(status, data)
      Rack::Response.new([JSON.dump(data)], status, { 'Content-Type' => 'application/json' })
    end
  end
end
