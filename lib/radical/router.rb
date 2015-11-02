module Radical
  class Router
    class RequestUnmatchedError < RuntimeError
      attr_reader :request

      def initialize(request)
        @request = request
      end
    end

    attr_reader :routes

    def initialize(routes = nil)
      @routes = routes || Route.registered_routes.map(&:new)
    end

    def route(requests)
      requests.reduce({}) do |response, request|
        deep_merge(response, handle_request(request))
      end
    end

    private

    def handle_request(request)
      response = routes.reduce({}) do |response, route|
        deep_merge(response, route.handle(request) || {})
      end

      if response.empty?
        { errors: { request.join('.') => ['No routes matched request.'] } }
      else
        response
      end
    end

    def deep_merge(hash, other_hash)
      hash.merge(other_hash) do |key, oldval, newval|
        oldval = oldval.to_h if oldval.respond_to?(:to_h)
        newval = newval.to_h if newval.respond_to?(:to_h)

        if oldval.class.to_s == 'Hash' and newval.class.to_s == 'Hash'
          deep_merge(oldval, newval)
        else
          newval
        end
      end
    end
  end
end
