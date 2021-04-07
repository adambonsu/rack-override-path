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
    [200, { 'Content-Type' => 'text/plain' }, ['OK']]
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
  let(:default_app_response) { MockRackApp.new.call(default_rack_environment) }
  let(:default_app_response_status) { default_app_response[0] }
  let(:default_app_response_headers) { default_app_response[1] }
  let(:default_app_response_body) { default_app_response[2].join }

  def configure_override(override)
    response = request.post('/override/path', input: override.to_json)
    expect(response.status).to eq 200
    response
  end

  def configured_override_for(path)
    override = { 'path' => path }
    response = request.get('/override/path', input: override.to_json)
    expect(response.status).to eq 200
    response.body
  end

  context 'No override configured' do
    it 'Returns web app response' do
      response = request.get('/path/to/somewhere')
      expect(response.status).to eq default_app_response_status
      expect(response.headers).to eq default_app_response_headers
      expect(response.body).to eq default_app_response_body
    end
  end
  context 'Override configured' do
    let(:override) { { 'path' => '/index.html' } }
    context 'Delay overridden by 5 seconds' do
      let(:overridden_delay) { 5 }
      before do
        override['delay'] = overridden_delay
        configure_override(override)
      end
      it '5 second Delay Overridden for Specified Path' do
        expect(JSON.parse(configured_override_for(override['path'])).first['delay']).to eq overridden_delay
      end
      it 'Response to Overridden Request takes about 5 seconds to respond'
    end
    context 'Headers overridden' do
      context 'No Headers configured' do
        it 'Override Headers is empty'
        it 'Response to Overridden Request has no Headers'
      end
      context 'Single Header configured' do
        it 'Override has one Header'
        it 'Response to Overridden Request contains configured Header'
      end
      context 'Multiple Headers configured' do
        it 'Override contains configured Headers'
        it 'Response to Overridden Request contains configured Headers'
      end
    end
    context 'Body overridden' do
      it 'Override contains configured Body'
      it 'Response to Overridden Request contains configured Body'
    end
    context 'Status overridden' do
      it 'Override contains configured Status'
      it 'Response to Overridden Request contains configured Status'
    end
    context 'Method overridden' do
      it 'Override contains configured Method'
      it 'Response to Overridden Method Request is overridden'
      it 'Non-Overridden Method Requests return App response'
    end
    context 'Request overridden path' do
      let(:overridden_status) { 206 }
      let(:override) { { 'status' => overridden_status } }
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
        response = request.get '/override/path'
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
