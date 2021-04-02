## Override parameters
Delay
Status
Body

## Examples

POST http://localhost:8080/override/path
{
  "delay": 2,
  "status": 404,
  "body": "Nothing found",
  "path": ".*videos.*"
}

GET http://localhost:8080/videos
=> "Nothing found" (After a 2 second delay)


POST http://localhost:8080/override
{
"delay": 2,
  "status": 404,
  "body": "Nothing found",
  "path": "/path/i/just/made/up"
}

POST http://localhost:8080/override
{
  "status": 202,
  "body": "Welcome to infinity",
  "path": "/path/i/just/made/up"
}

POST /override
{
  "delay": 300,
  "status": 404,
  "body": "No match found",
  "path": "*videos*",
}

DEFAULTS:
{
  "delay": 0,
  "status": 200,
  "body": ""
}


DELETE /override
{
  "path": *
}

GET /override/?:path?
[
  {
    "delay": 300,
    "status": 404,
    "body": "No match found",
    "path": "*videos*",
  }
]