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
      snapshot = {}

      record.custom_snapshot_attributes.each do |key, attribute|
        snapshot[key] = record.send(attribute)
      end

      snapshot[:object] = extract_attributes(record_snapshot_attrs, record) if record_snapshot_attrs.any?

      deep_snapshot_attrs&.each do |association_name, attributes|
        association = record.send(association_name)

        snapshot["#{association_name}_object"] = if association.class.name == 'ActiveRecord::Associations::CollectionProxy'
                                                           association.map { |model| extract_attributes(attributes, model) }
                                                         else
                                                           extract_attributes(attributes, association)
                                                         end
      end

      snapshot
    end

    def extract_attributes(attributes, model)
      return {} if model.blank?

      attributes.inject({}) do |collected_attrs, attr|
        collected_attrs.merge(attr => model.send(attr))
      end
    end

    def record_snapshot_attrs
      @record_snapshot_attrs ||= record.attributes_to_save_on_snapshot.select { |attr| attr.is_a? Symbol }
    end

    def deep_snapshot_attrs
      @deep_snapshot_attrs ||= record.attributes_to_save_on_snapshot.select { |attr| attr.is_a? Hash }.first
    end
  end
end
