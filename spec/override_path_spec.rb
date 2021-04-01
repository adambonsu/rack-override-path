# frozen_string_literal: true

require 'rubygems'
require 'rack'
require 'rack/test'

describe Rack::OverridePath do
  let(:app) do
    app = Rack::Builder.new do
      use Rack::OverridePath
      run lambda {|env| [200, { 'Content-Type' => 'text/plain' }, ['Hello World']]}
    end
    app
  end

  context 'no override configured' do
    it 'returns successful response' do
      get '/path/to/somewhere'
      expect(last_response.status).to eq 200
      expect(last_response.body).to eq 'Hello World'
    end
  end
  context 'override configured' do
    context 'override request has no body' do
      it 'fails - bad config' do
        post '/override/path'
        expect(last_response.status).to eq 400
      end
    end
  end
end
