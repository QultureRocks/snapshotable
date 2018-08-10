require "rails/generators"
require "rails/generators/migration"
require "active_record"
require "rails/generators/active_record"

module Snapshotable
  module Generators
    class CreateGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path("templates", __dir__)

      argument :snapshotable_model, type: :string
      class_option :has_one, type: :array, default: [], desc: 'has_one relations to add to the snapshot'
      class_option :has_many, type: :array, default: [], desc: 'has_many relations to add to the snapshot'

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime("%Y%m%d%H%M%S"), "%.14d" % next_migration_number].max
        else
          "%.3d" % next_migration_number
        end
      end

      def copy_migration
        migration_template "create.rb", "db/migrate/create_#{snapshotable_model}_snapshots.rb", migration_version: migration_version
      end

      def migration_version
        if ActiveRecord::VERSION::MAJOR >= 5
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        end
      end

      def has_one
        options['has_one']
      end

      def has_many
        options['has_many']
      end
    end
  end
end