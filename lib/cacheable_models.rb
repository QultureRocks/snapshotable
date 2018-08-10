require 'services/cache_attributes'

module CacheableModels

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class_attribute :attributes_to_cache, :instance_writer => false
      class_attribute :attributes_to_ignore_on_diff, :instance_writer => false

      self.attributes_to_cache = []
      self.attributes_to_ignore_on_diff = []

      unless instance_methods.include?(:cache!)
        def cache!
          CacheAttributes.new(self).call
        end
      end
    end
  end

  module ClassMethods
    def cache(*attributes)
      self.attributes_to_cache = attributes
    end

    def cache_ignore_diff(*attributes)
      self.attributes_to_ignore_on_diff = attributes
    end
  end
end

ActiveSupport.on_load :active_record do
  include Cacheable
end
