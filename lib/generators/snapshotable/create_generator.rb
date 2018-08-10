# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/migration'
require 'active_record'
require 'rails/generators/active_record'

module Snapshotable
  module Generators
    class CreateGenerator < Rails::Generators::Base
      include Rails::Generators::Migration

      source_root File.expand_path('templates', __dir__)

      argument :snapshotable_model, type: :string
      class_option :has_one, type: :array, default: [], desc: 'has_one relations to add to the snapshot'
      class_option :has_many, type: :array, default: [], desc: 'has_many relations to add to the snapshot'

      def generate_migration_and_model
        migration_template 'migration.rb', "db/migrate/create_#{snapshotable_model}_snapshots.rb", migration_version: migration_version
        template 'model.rb', "app/models/#{model_underscored}_snapshot.rb"
      end

      # Implement the required interface for Rails::Generators::Migration.
      def self.next_migration_number(dirname) #:nodoc:
        next_migration_number = current_migration_number(dirname) + 1
        if ActiveRecord::Base.timestamped_migrations
          [Time.now.utc.strftime('%Y%m%d%H%M%S'), format('%.14d', next_migration_number)].max
        else
          format('%.3d', next_migration_number)
        end
      end

      def migration_version
        "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]" if ActiveRecord::VERSION::MAJOR >= 5
      end

      def active_record_class
        ActiveRecord::VERSION::MAJOR >= 5 ? 'ApplicationRecord' : 'ActiveRecord::Base'
      end

      def relations_has_one
        options['has_one']
      end

      def relations_has_many
        options['has_many']
      end

      def model_underscored
        snapshotable_model.underscore
      end

      def model_camelcased
        snapshotable_model.camelcase
      end
    end
  end
end
