# frozen_string_literal: true

require 'services/snapshot_creator'

module Snapshotable
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/BlockLength
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class_attribute :attributes_to_save_on_snapshot, instance_writer: false
      class_attribute :attributes_to_ignore_on_diff, instance_writer: false
      class_attribute :custom_snapshot_attributes, instance_writer: false

      self.attributes_to_save_on_snapshot = []
      self.attributes_to_ignore_on_diff = %w[id created_at updated_at]
      self.custom_snapshot_attributes = {}

      unless instance_methods.include?(:take_snapshot!)
        def take_snapshot!
          snapshot = SnapshotCreator.new(self).call
          snapshot_model = Object.const_get("#{self.class.name}Snapshot")

          snapshot_model.create!(snapshot) if should_create_new_snapshot?(snapshot)
        end
      end

      unless instance_methods.include?(:last_snapshot)
        def last_snapshot
          send("#{self.class.name.downcase}_snapshots").last
        end
      end

      unless instance_methods.include?(:should_create_cache?)
        def should_create_new_snapshot?(snapshot)
          return true if last_snapshot.nil?

          snapshot_to_compare = last_snapshot
                                .attributes
                                .except(*attributes_to_ignore_on_diff)
                                .with_indifferent_access

          HashDiff.diff(snapshot_to_compare, snapshot.with_indifferent_access).any?
        end
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/BlockLength

  module ClassMethods
    def snapshot(*attributes)
      self.attributes_to_save_on_snapshot = attributes
    end

    def snapshot_ignore_diff(*attributes)
      self.attributes_to_ignore_on_diff = attributes.map(&:to_s)
    end

    def custom_snapshot(*attributes)
      self.custom_snapshot_attributes = attributes.first
    end
  end
end

ActiveSupport.on_load :active_record do
  include Snapshotable
end
