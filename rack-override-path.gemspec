# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name                  = 'rack-override-path'
  s.version               = '0.2.0'
  s.summary               = 'Rack middleware that overrides responses for web applications'
  s.description           = 'A Rack middleware gem that overrides responses for web applications'
  s.authors               = ['Adam Bonsu']
  s.email                 = 'adam@bonsu.io'
  s.files                 = %w[lib/override_path.rb lib/rack/override_path.rb lib/rack/override-path.rb]
  s.homepage              = 'https://github.com/adambonsu/rack-override-path'
  s.license               = 'MIT'
  s.required_ruby_version = '>= 2.7.0'
  s.metadata              = {
    'changelog_uri' => 'https://github.com/adambonsu/rack-override-path/blob/main/CHANGELOG.md'
  }
end
