# frozen_string_literal: true

require 'rubygems'
require 'rack'
require 'rack/test'

class MockRackApp
  attr_reader :request_body

  def initialize
    @request_headers = {}
  end

  def call(env)
    @env = env
    @request_body = env['rack.input'].read
    [200, {'Content-Type' => 'text/plain'}, ['OK']]
  end

  def [](key)
    @env[key]
  end
end

describe Rack::OverridePath do
  let(:app) { MockRackApp.new }
  subject { Rack::OverridePath.new(app) }
  let(:request) { Rack::MockRequest.new(subject) }
  let(:default_rack_environment) { Rack::MockRequest::DEFAULT_ENV }
  let(:default_app_response) {  MockRackApp.new.call(default_rack_environment) }
  let(:default_app_response_status) { default_app_response[0] }
  let(:default_app_response_headers) { default_app_response[1] }
  let(:default_app_response_body) { default_app_response[2].join }

  context 'No override configured' do
    it 'Returns web app response' do
      response = request.get('/path/to/somewhere')
      expect(response.status).to eq default_app_response_status
      expect(response.headers).to eq default_app_response_headers
      expect(response.body).to eq default_app_response_body
    end
  end
  context 'Override configured' do
    let(:overridden_status) { 206 }
    let(:override) { { 'status' => overridden_status } }
    context 'Request overridden path' do
      context 'Literal path match' do
        context 'Literal path' do
          before do
            override['path'] = '/index.html'
            response = request.post('/override/path', input: override.to_json)
            expect(response.status).to eq 200
          end

          it 'Returns overridden response' do
            response = request.get '/index.html'
            expect(response.status).to eq override['status']
          end
        end
      end
      context 'Regex path match' do
        context 'literal path' do
          before do
            override['path'] = '.*videos.*'
            response = request.post('/override/path', input: override.to_json)
            expect(response.status).to eq 200
          end

          it 'Returns overridden response' do
            response = request.get '/path/to/videos/location'
            expect(response.status).to eq override['status']
          end
        end
      end
    end
    context 'Request path that has not been overridden' do
      it 'Returns web app response' do
        response = request.get('/path/to/somewhere')
        expect(response.status).to eq default_app_response_status
        expect(response.headers).to eq default_app_response_headers
        expect(response.body).to eq default_app_response_body
      end
    end
  end
  describe 'GET /override/path' do
    context 'No Overrides configured' do
      it 'Empty Overrides list' do
        response = request.get'/override/path'
        expect(response.status).to eq 200
        expect(JSON.parse(response.body)).to be_empty
      end
    end
    context 'Override configured' do
      context 'One Override configured' do
        let(:override) { { 'status' => '999', 'path' => '.*videos.*' } }
        before do
          response = request.post '/override/path', input: override.to_json
          expect(response.status).to eq 200
        end

        it 'Override listed' do
          response = request.get '/override/path'
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)).to eq [override]
        end
      end
      context 'Multiple overrides configured' do
        let(:overrides) { [{ 'status' => '999', 'path' => '.*videos.*' }, { 'status' => '808', 'path' => '.*index.html$' }] }
        before do
          overrides.each do |override|
            response = request.post '/override/path', input: override.to_json
            expect(response.status).to eq 200
          end
        end

        it 'Overrides stacked - last override at the top' do
          response = request.get '/override/path'
          expect(response.status).to eq 200
          expect(JSON.parse(response.body)).to eq overrides.reverse
        end
      end
    end
  end
end
