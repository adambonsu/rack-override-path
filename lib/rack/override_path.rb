# frozen_string_literal: true

require 'json'
require 'rack'

module Rack
  class OverridePath
    DEFAULT_BODY = ''
    DEFAULT_DELAY = 0
    DEFAULT_HEADERS = {}.freeze
    DEFAULT_STATUS = 200
    OVERRIDE_ENDPOINT = '/override/path'
    OVERRIDE_KEYS = %w[body delay headers status].freeze

    def initialize(app)
      @app = app
      @overridden_paths = []
    end

    def call(env)
      req = request(env)
      if override_path?(req)
        override_path(req)
      elsif path_overridden?(req.path) && override_matches_method?(req)
        handle_override(req.path, env)
      elsif get_override?(req)
        get_override(req)
      elsif delete_overrides?(req)
        delete_overrides(req)
      else
        @app.call(env)
      end
    end

    def delete_overrides(req)
      @overridden_paths.clear
      get_override(req)
    end

    def delete_overrides?(req)
      override_endpoint?(req) && req.delete?
    end

    def override_matches_method?(req)
      o = override(req.path)
      o['method'].nil? ? true : o['method'].downcase == req.request_method.downcase
    end

    def override_endpoint?(req)
      req.path == '/override/path'
    end

    def get_override?(req)
      override_endpoint?(req) && req.get?
    end

    def get_override(_req)
      [200, { 'Content-Type' => 'application/json' }, [@overridden_paths.to_json]]
    end

    def override(path)
      @overridden_paths.find do |override|
        override_path = literal_path?(override['path']) ? literal_path(override['path']) : override['path']
        path.match(Regexp.new(override_path))
      end
    end

    def literal_path?(path)
      path[0] == '/'
    end

    def literal_path(path)
      "^#{path}$"
    end

    def override_path?(req)
      override_endpoint?(req) && req.post?
    end

    def override_path(req)
      payload = request_body_json(req)
      if valid?(payload)
        @overridden_paths.prepend(payload)
        override_path_successful_response(payload)
      else
        override_path_failed_response_no_body
      end
    end

    def valid?(payload)
      payload&.key?('path') && at_least_one_override_key?(payload)
    end

    def at_least_one_override_key?(payload)
      !(payload.keys & OVERRIDE_KEYS).empty?
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
      [response_status, response_headers, prepare_response_body_for_rack(response_body)]
    end

    def prepare_response_body_for_rack(response_body)
      response_body = response_body.is_a?(Hash) ? response_body.to_json : response_body
      response_body.is_a?(Array) ? response_body : [response_body]
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
