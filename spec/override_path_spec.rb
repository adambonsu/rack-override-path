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
    it 'returns successful response' do
      get '/path/to/somewhere'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'Hello World'
    end
  end
  describe 'Configure override' do
    describe 'Failures' do
      context 'Override request' do
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
    end
    describe 'success' do
    end
  end
  describe 'override configured'
end
