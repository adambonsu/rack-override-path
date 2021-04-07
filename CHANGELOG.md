# Changelog
All notable changes to this project will be documented in this file.

For info on how to format all future additions to this file please reference [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2020-04-07
### Added
- `method` (PUT, POST, etc) Filter to more tightly specify an override  [@adambonsu](https://github.com/adambonsu).
- Changelog [@adambonsu](https://github.com/adambonsu).
- Readme section on how to Configure an Override Response [@adambonsu](https://github.com/adambonsu).
- Readme section on Available Override Parameters [@adambonsu](https://github.com/adambonsu).
- Readme section on Available Filters [@adambonsu](https://github.com/adambonsu).


## [0.0.2] - 2020-04-02
### Added
- List Overridden Paths with `GET /override/path` [@adambonsu](https://github.com/adambonsu).

### Changed
- `path` can be either a literal or a regular expression [@adambonsu](https://github.com/adambonsu).

## [0.0.1] - 2020-04-02
### Added
- Configure Override Path with `POST /override/path` [@adambonsu](https://github.com/adambonsu).
- Override Path Gem. [@adambonsu](https://github.com/adambonsu).
- Override Parameters: `body`, `delay`, `headers`, `status` [@adambonsu](https://github.com/adambonsu).


[Unreleased]: https://github.com/adambonsu/rack-override-path/compare/v0.1.0...HEAD
[0.0.2]: https://github.com/adambonsu/rack-override-path/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/adambonsu/rack-override-path/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/adambonsu/rack-override-path/v0.0.1