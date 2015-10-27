require 'rack'

module Radical
  class Application
    attr_writer :router

    def call(env)
      request = Rack::Request.new(env)
      router.route(parse_routes(request[:routes]))
    end

    private

    def router
      @router ||= Router.new
    end

    def parse_routes(routes)
      routes.map { |route| route.split('.').map(&:to_sym) }
    end
  end
end
