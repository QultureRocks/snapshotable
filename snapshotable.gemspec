lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snapshotable/version'

Gem::Specification.new do |s|
  s.name          = 'snapshotable'
  s.version       = Snapshotable::VERSION
  s.authors       = ['João Batista Marinho', 'Manuel Puyol']
  s.email         = 'engineering@qulture.rocks'

  s.summary       = 'Caches a model in a time period.'
  s.description   = 'Caches a model in a time period'
  s.homepage      = 'https://github.com/QultureRocks/snapshotable'
  s.license       = 'MIT'

  s.files = Dir['LICENSE.txt', 'README.md', 'lib/**/*']
  s.require_paths = ['lib']

  s.required_ruby_version = '>= 2.1.7'

  s.add_runtime_dependency 'activesupport', ['>= 4.1', '< 6']
  s.add_runtime_dependency 'hashdiff', ['>= 0.3', '< 1']

  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'pry-rails', ['>= 0.3', '< 1']
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
