# frozen_string_literal: true

require 'json'
require 'rack'

module Rack
  class OverridePath
    DEFAULT_BODY = ''
    DEFAULT_DELAY = 0
    DEFAULT_HEADERS = {}.freeze
    DEFAULT_STATUS = 200

    def initialize(app)
      @app = app
      @overridden_paths = []
    end

    def call(env)
      req = request(env)
      if override_path?(req)
        override_path(req)
      elsif path_overridden?(req.path)
        handle_override(req.path, env)
      else
        @app.call(env)
      end
    end

    def override(path)
      @overridden_paths.find { |override| path.match(Regexp.new(override['path'])) }
    end

    def override_path?(req)
      req.post? && req.path == '/override/path'
    end

    def override_path(req)
      payload = request_body_json(req)
      if payload
        @overridden_paths.prepend(payload)
        override_path_successful_response(payload)
      else
        override_path_failed_response_no_body
      end
    end

    def override_path_successful_response(payload)
      [200, { 'Content-Type' => 'application/json' }, [payload.to_json]]
    end

    def override_path_failed_response_no_body
      [400, { 'Content-Type' => 'application/json' }, [{ 'message' => 'No body provided' }.to_json]]
    end

    def path_overridden?(path)
      override(path).nil? ? false : true
    end

    def handle_override(path, env)
      o = override(path)
      handle_override_delay(o['delay']) if o['delay']
      status, headers, body = @app.call(env) unless o['body']
      handle_override_response(o, status, headers, body)
    end

    def handle_override_delay(delay)
      sleep delay
    end

    def handle_override_response(override, status, headers, body)
      response_status = override['status'] || status || DEFAULT_STATUS
      response_headers = override['headers'] || headers || DEFAULT_HEADERS
      response_body = override['body'] || body || DEFAULT_BODY
      response_body = Array(response_body)
      [response_status, response_headers, response_body]
    end

    def request(env)
      Rack::Request.new(env)
    end

    def request_body_json(req)
      JSON.parse(request_body(req))
    rescue StandardError => _e
      nil
    end

    def request_body(req)
      req.body.rewind
      req.body.read
    rescue StandardError => _e
      ''
    end
  end
end
