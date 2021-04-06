# frozen_string_literal: true

require 'rubygems'
require 'rack'
require 'rack/test'

describe Rack::OverridePath do
  let(:app) do
    app = Rack::Builder.new do
      use Rack::OverridePath
      run ->(_env) { [200, { 'Content-Type' => 'text/plain' }, ['Hello World']] }
    end
    app
  end

  context 'No override configured' do
    it 'returns web app response' do
      get '/path/to/somewhere'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'Hello World'
    end
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
        context 'Body not specifying at least one override parameter' do
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
end
