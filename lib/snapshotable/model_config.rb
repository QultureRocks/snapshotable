# frozen_string_literal: true

module Snapshotable
  class ModelConfig
    DEFAULT_ATTRIBUTES = [].freeze
    DEFAULT_IGNORE_ATTRIBUTES = %w[id created_at updated_at].freeze
    DEFAULT_CUSTOM_ATTRIBUTES = {}.freeze

    def initialize(model)
      @model = model
    end

    def setup_snapshot
      setup_snapshot_names
      setup_variables
      setup_association(@model)

      @model.send :include, ::Snapshotable::Model::InstanceMethods
    end

    def setup_snapshot_attributes(attributes)
      setup_snapshot unless snapshot_configured?
      @model.attributes_to_save_on_snapshot = attributes || DEFAULT_ATTRIBUTES
    end

    def setup_snapshot_ignore(attributes)
      setup_snapshot unless snapshot_configured?
      @model.attributes_to_ignore_on_diff = attributes || DEFAULT_IGNORE_ATTRIBUTES
    end

    def setup_snapshot_custom(attributes)
      setup_snapshot unless snapshot_configured?
      @model.custom_snapshot_attributes = attributes || DEFAULT_CUSTOM_ATTRIBUTES
    end

    def snapshot_configured?
      @model.respond_to?(:snapshot_configured) && @model.snapshot_configured
    end

    def setup_variables
      setup_attributes_to_save_on_snapshot
      setup_attributes_to_ignore_on_diff
      setup_custom_snapshot_attributes

      @model.class_attribute :snapshot_configured
      @model.snapshot_configured = true
      @model.send :attr_accessor, :snapshot_configured
    end

    def setup_attributes_to_save_on_snapshot
      @model.class_attribute :attributes_to_save_on_snapshot, instance_writer: false
      @model.attributes_to_save_on_snapshot = DEFAULT_ATTRIBUTES
      @model.send :attr_accessor, :attributes_to_save_on_snapshot
    end

    def setup_attributes_to_ignore_on_diff
      @model.class_attribute :attributes_to_ignore_on_diff, instance_writer: false
      @model.attributes_to_ignore_on_diff = DEFAULT_IGNORE_ATTRIBUTES
      @model.send :attr_accessor, :attributes_to_ignore_on_diff
    end

    def setup_custom_snapshot_attributes
      @model.class_attribute :custom_snapshot_attributes, instance_writer: false
      @model.custom_snapshot_attributes = DEFAULT_CUSTOM_ATTRIBUTES
      @model.send :attr_accessor, :custom_snapshot_attributes
    end

    def setup_snapshot_names
      @model.class_attribute :snapshot_association_name
      @model.snapshot_association_name = snapshot_association_name

      @model.class_attribute :snapshot_class_name
      @model.snapshot_class_name = snapshot_class_name

      @model.class_attribute :snapshot_foreign_key
      @model.snapshot_foreign_key = snapshot_foreign_key
    end

    def setup_association(klass)
      klass.has_many(
        klass.snapshot_association_name,
        class_name: klass.snapshot_class_name,
        dependent: :destroy
      )
    end

    def snapshot_class_name
      "#{@model.name}Snapshot"
    end

    def snapshot_association_name
      snapshot_class_name.pluralize.underscore.to_sym
    end

    def snapshot_foreign_key
      "#{@model.name.downcase}_id"
    end
  end
end
