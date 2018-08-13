# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
ENV["DB"] = "postgresql"

require 'bundler/setup'
require 'pry-rails'

require 'active_support'
require 'active_support/core_ext/string/strip'

require File.expand_path("dummy/config/environment", __dir__)
require "rspec/rails"

require 'snapshotable'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.use_transactional_fixtures = true

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
