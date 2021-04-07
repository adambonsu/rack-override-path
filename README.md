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

## Example webserver setup using webrick
```
require 'rack/override-path'
require 'webrick'

app = lambda do |_env|
[200, { 'Content-Type' => 'text/plain' }, ['Hello World']]
end

Rack::Handler::WEBrick.run Rack::OverridePath.new(app)
```

### Configure Override Response
Specify a `path`, with one or more Override Parameters.

Subsequent requests matching `path` will be overridden.
#### Example
```
POST /override/path
{
  "delay": 2,
  "headers": { "Content-Type": "text/plain" },
  "status": 404,
  "body": "Nothing found",
  "method": "GET",
  "path": "/index.html"
}
```
In the example above, `GET` requests for `/index.html` will respond with a `404` status with `Nothing found` in the body after a `2` second delay

The `path` can be literal (e.g `/index.html`) or a regular expression (e.g `.*videos.*`)

#### Available Override Parameters
At least one Override Parameter must be included in each Configured Override 
* `body`
* `delay` - should be an Integer value, in seconds
* `headers`
* `status` - should be an Integer value


#### Available Filters
Filters are optional
* `method` - acceptable values are `GET`,`PUT`, `POST`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS`. If `method` parameter is not specified, all methods for the matching `path` are overridden

### List Overridden Responses
#### Example
```
GET /override/path
[
    {
        "delay": 2,
        "headers": {
            "Content-Type": "text/plain"
        },
        "status": 404,
        "body": "Nothing found",
        "method": "GET",
        "path": "/index.html"
    }
]
```

### Delete all Overridden Responses
#### Example
```
DELETE /override/path
[]
```