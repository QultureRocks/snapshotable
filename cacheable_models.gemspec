
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "cacheable_models/version"

Gem::Specification.new do |s|
  s.name          = "cacheable_models"
  s.version       = CacheableModels::VERSION
  s.authors       = ["João Batista Marinho", "Manuel Puyol"]
  s.email         = ["manuelpuyol@gmail.com"]

  s.summary       = %q{Caches a model in a time period.}
  s.description   = %q{Caches a model in a time period.}
  s.homepage      = "TODO: Put your gem's website or public repo URL here."
  s.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if s.respond_to?(:metadata)
    s.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  s.files = Dir['README.md', 'lib/**/*']
  s.require_paths = ["lib"]

  s.add_runtime_dependency 'activesupport', '>= 4.1'

  s.add_development_dependency "bundler", "~> 1.16"
  s.add_development_dependency "rake", "~> 10.0"
  s.add_development_dependency "rspec", "~> 3.0"
end