# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = 'appush_client'
  s.version = '0.4'

  s.authors = ['Igor Guerrero']
  s.date = '2010-01-09'
  s.description = "Ruby client library for Appush PUSH service."
  s.email = ['igor@appush.com']
  s.homepage = 'http://appush.com'
  s.files = ['appush_client.gemspec', 'CONTRIBUTORS', 'LICENSE', 'README.md', 'lib/appush_client.rb',
    'spec/appush_client_spec.rb']
  s.summary = "Ruby client library for Appush PUSH service."

  s.add_dependency 'rest-client', '>= 1.3.1'
end
