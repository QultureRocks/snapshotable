$:.push File.expand_path('../lib', __FILE__)
require 'cacheable/version'

Gem::Specification.new do |s|
  s.name = 'cacheable'
  s.version = Cacheable::VERSION.dup
  s.summary = 'Caches a model in a time period.'
  s.email = 'engineering@qulture.rocks'
  s.description = 'Caches a model in a time period.'
  s.authors = ['João Batista Marinho', 'Manuel Puyol']

  s.files = Dir['README.md', 'lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.3.4'
end
