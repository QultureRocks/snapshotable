require 'services/cache_attributes'

module CacheableModels
  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class_attribute :attributes_to_cache, instance_writer: false
      class_attribute :attributes_to_ignore_on_diff, instance_writer: false
      class_attribute :custom_cache_attributes, instance_writer: false

      self.attributes_to_cache = []
      self.attributes_to_ignore_on_diff = ['id', 'created_at', 'updated_at']
      self.custom_cache_attributes = {}

      unless instance_methods.include?(:cache!)
        def cache!
          cached_attributes = CacheAttributes.new(self).call
          cache_model = Object.const_get("#{self.class.name}Cache")

          cache_model.create!(cached_attributes) if should_create_new_cache?(cached_attributes)
        end
      end

      unless instance_methods.include?(:last_cache)
        def last_cache
          self.send("#{self.class.name.downcase}_caches").last
        end
      end

      unless instance_methods.include?(:should_create_cache?)
        def should_create_new_cache?(cache_attributes)
          return true if last_cache.nil?

          attributes_to_compare = last_cache
                                  .attributes
                                  .except(*self.attributes_to_ignore_on_diff)
                                  .with_indifferent_access

          HashDiff.diff(attributes_to_compare, cache_attributes.with_indifferent_access).any?
        end
      end
    end
  end

  module ClassMethods
    def cache(*attributes)
      self.attributes_to_cache = attributes
    end

    def cache_ignore_diff(*attributes)
      self.attributes_to_ignore_on_diff = self.attributes_to_ignore_on_diff + attributes.map(&:to_s)
    end

    def custom_cache(*attributes)
      self.custom_cache_attributes = attributes.first
    end
  end
end

ActiveSupport.on_load :active_record do
  include CacheableModels
end
