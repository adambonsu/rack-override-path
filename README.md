# rack-override-path
`Rack::OverridePath` overrides responses for web applications

## Installation

Install the gem:

`gem install rack-override-path`

Or in your Gemfile:

```ruby
gem 'rack-override-path'
```

## How to use
### Configure path
Specify a `path`, with one or more Override Parameters.
```
POST /override/path
{
  "delay": 2,
  "headers": { "Content-Type": "text/plain" },
  "status": 404,
  "body": "Nothing found",
  "path": "/index.html"
}
```
Subsequent requests matching `path` will be overridden.
In the example above, requests for `/index.html` will respond with a `404` status with `Nothing found` in the body after a `2` second delay

The `path` can be literal (e.g `/index.html`) or a regular expression (e.g `.*videos.*`)
Available Override Parameters: `delay`, `status`, `headers`, `body`


## Example webserver setup using webrick
```
require 'rack/override-path'
require 'webrick'

app = lambda do |_env|
[200, { 'Content-Type' => 'text/plain' }, ['Hello World']]
end

Rack::Handler::WEBrick.run Rack::OverridePath.new(app)
```
