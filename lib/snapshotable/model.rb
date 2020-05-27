# frozen_string_literal: true

require 'services/snapshot_creator'
require 'snapshotable/model_config'
require 'hashdiff'

module Snapshotable
  module Model
    def self.included(base)
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def snapshot(*attributes)
        snapshotable_config.setup_snapshot_attributes(attributes)
      end

      def snapshot_ignore_diff(*attributes)
        snapshotable_config.setup_snapshot_ignore(attributes)
      end

      def custom_snapshot(*attributes)
        snapshotable_config.setup_snapshot_custom(attributes)
      end

      def snapshotable_config
        ::Snapshotable::ModelConfig.new(self)
      end
    end

    module InstanceMethods
      def take_snapshot!(force = false)
        snapshot = SnapshotCreator.new(self).call
        snapshot_class.create!(snapshot) if force || should_create_new_snapshot?(snapshot)
      end

      def snapshots
        send(snapshot_association_name)
      end

      def last_snapshot_before(time = Time.zone.now)
        snapshots.order(created_at: :desc).where('created_at < ?', time).first
      end

      def last_snapshot
        snapshots.order(created_at: :desc).first
      end

      def snapshot_class
        Object.const_get(snapshot_class_name)
      end

      def should_create_new_snapshot?(snapshot)
        return true if last_snapshot.nil?

        snapshot_to_compare = last_snapshot
                              .attributes
                              .except(*self.class.attributes_to_ignore_on_diff)
                              .with_indifferent_access

        Hashdiff.diff(snapshot_to_compare, snapshot.with_indifferent_access).any?
      end
    end
  end
end
