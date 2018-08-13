# frozen_string_literal: true

module Snapshotable
  class SnapshotCreator
    def initialize(record)
      @record = record
    end

    def call
      snapshot_attrs
    end

    private

    attr_reader :record

    def snapshot_attrs
      snapshot = {
        "#{record.snapshot_foreign_key}": record.id
      }

      add_custom_attributes(snapshot) if custom_snapshot_attributes&.any?

      snapshot[:object] = extract_attributes(record_snapshot_attrs, record) if record_snapshot_attrs.any?

      add_deep_snapshot_objects(snapshot)

      snapshot
    end

    def add_custom_attributes(snapshot)
      custom_snapshot_attributes.each do |key, attribute|
        snapshot[key] = record.send(attribute)
      end
    end

    def add_deep_snapshot_objects(snapshot)
      deep_snapshot_attrs&.each do |association_name, attributes|
        association = record.send(association_name)

        snapshot["#{association_name}_object"] = if association.class.name == 'ActiveRecord::Associations::CollectionProxy'
                                                   association.map { |model| extract_attributes(attributes, model) }
                                                 else
                                                   extract_attributes(attributes, association)
                                                 end
      end
    end

    def extract_attributes(attributes, model)
      return {} if model.blank?

      attributes.inject({}) do |collected_attrs, attr|
        collected_attrs.merge(attr => model.send(attr))
      end
    end

    def record_snapshot_attrs
      @record_snapshot_attrs ||= record.class.attributes_to_save_on_snapshot.select { |attr| attr.is_a? Symbol }
    end

    def deep_snapshot_attrs
      @deep_snapshot_attrs ||= record.class.attributes_to_save_on_snapshot.select { |attr| attr.is_a? Hash }.first
    end

    def custom_snapshot_attributes
      @custom_snapshot_attributes ||= record.class.custom_snapshot_attributes.first
    end
  end
end
