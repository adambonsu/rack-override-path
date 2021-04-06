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

  context 'No override configured' do
    it 'returns web app response' do
      get '/path/to/somewhere'
      # to do: improve - check app response without overrides
      # confirm that no overrides configured also
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'Hello World'
    end
  end
  context 'Override configured' do
    let(:overridden_status) { 206 }
    let(:override) { { 'status' => overridden_status } }
    context 'request overridden path' do
      context 'literal path match' do
        context 'literal path' do
          before do
            override['path'] = '/index.html'
            response = request.post('/override/path', input: override.to_json)
            expect(response.status).to eq 200
          end

          it 'returns overridden response' do
            response = request.get '/index.html'
            expect(response.status).to eq override['status']
          end
        end
      end
      context 'regex path match' do
        context 'literal path' do
          before do
            override['path'] = '.*videos.*'
            response = request.post('/override/path', input: override.to_json)
            expect(response.status).to eq 200
          end

          it 'returns overridden response' do
            response = request.get '/path/to/videos/location'
            expect(response.status).to eq override['status']
          end
        end
      end
    end
    context 'request path that has not been overridden'
  end
  describe 'POST /override/path' do
    context 'Failures' do
      context 'No body' do
        it '400 - bad config' do
          post '/override/path'
          expect(last_response.status).to eq 400
        end
      end
      context 'Empty body' do
        it '400 - bad config' do
          post '/override/path', {}
          expect(last_response.status).to eq 400
        end
      end
      context 'Body not in json format' do
        it '400 - bad config' do
          post '/override/path', 'delay' => 1, 'status' => 808, 'body' => 'la la la'
          expect(last_response.status).to eq 400
        end
      end
      context 'Body in json format' do
        context 'Body missing path parameter' do
          context 'Only delay parameter specified' do
            it '400 - bad config' do
              data = {
                'delay' => 1
              }
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 400
            end
          end
          context 'Only headers parameter specified' do
            it '400 - bad config' do
              data = {
                'headers' => ['Content-Type' => 'text/plain']
              }
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 400
            end
          end
          context 'Only status parameter specified' do
            it '400 - bad config' do
              data = {
                'status' => 808
              }
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 400
            end
          end
          context 'Only body parameter specified' do
            it '400 - bad config' do
              data = {
                'body' => 'la la la'
              }
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 400
            end
          end
        end
        context 'Body not specifying at least one an override parameter' do
          it '400 - bad config' do
            data = {
              'path' => '.*videos.*'
            }
            post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
            expect(last_response.status).to eq 400
          end
        end
      end
    end
    context 'Success' do
      context 'Body in json format with path and at least one override parameter' do
        context 'Path parameter specified' do
          let(:data) { { 'path' => '.*videos.*' } }
          context 'Delay parameter specified' do
            it '200 - Success' do
              data['delay'] = 1
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 200
            end
          end
          context 'Headers parameter specified' do
            it '200 - Success' do
              data['headers'] = ['Content-Type' => 'text/plain']
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 200
            end
          end
          context 'Status parameter specified' do
            it '200 - Success' do
              data['status'] = 808
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 200
            end
          end
          context 'Body parameter specified' do
            it '200 - Success' do
              data['body'] = 'Jambo Jambo'
              post '/override/path', data.to_json, 'CONTENT_TYPE' => 'application/json'
              expect(last_response.status).to eq 200
            end
          end
        end
      end
    end
  end
  describe 'GET /override/path' do
    context 'override not configured' do
      it 'no overrides listed' do
        get '/override/path'
        expect(last_response.status).to eq 200
        expect(JSON.parse(last_response.body)).to be_empty
      end
    end
    xcontext 'override configured' do
      context 'one override configured' do
        let(:override) { { 'path' => '.*videos.*' } }

        it 'override listed' do
          post '/override/path', override.to_json
          get '/override/path'
          expect(last_response.status).to eq 200
          expect(JSON.parse(last_response.body)).to eq override
        end
      end
      context 'multiple overrides configured' do
        it 'overrides listed'
        it 'overrides stacked - last override at the top'
      end
    end
  end
end
