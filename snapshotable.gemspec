# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snapshotable/version'

Gem::Specification.new do |s|
  s.name          = 'snapshotable'
  s.version       = Snapshotable::VERSION
  s.authors       = ['João Batista Marinho', 'Manuel Puyol']
  s.email         = 'engineering@qulture.rocks'

  s.summary       = 'Stores a model attributes in a time period.'
  s.description   = 'Stores a model attributes in a time period'
  s.homepage      = 'https://github.com/QultureRocks/snapshotable'
  s.license       = 'MIT'

  s.files = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.3.0'

  s.add_runtime_dependency 'activerecord', ['>= 4.1', '< 6.1']
  s.add_runtime_dependency 'activesupport', ['>= 4.1', '< 6.1']
  s.add_runtime_dependency 'hashdiff', '>= 1', '< 2'

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'factory_bot_rails', ['>= 4.0', '< 6.1']
  s.add_development_dependency 'pg', '~> 1.2.3'
  s.add_development_dependency 'pry-rails', ['>= 0.3', '< 1']
  s.add_development_dependency 'rake', '~> 13.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'rspec-rails', '~> 3.0'
  s.add_development_dependency 'rubocop', ['>= 0.3', '< 1']
end
