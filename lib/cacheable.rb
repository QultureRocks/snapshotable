require 'services/cache_attributes'

module Cacheable

  def self.included(base)
    base.class_eval do
      extend ClassMethods
      class_attribute :attributes_to_cache, :instance_writer => false
      class_attribute :attributes_to_ignore_on_diff, :instance_writer => false

      self.attributes_to_cache = []
      self.attributes_to_ignore_on_diff = []
    end
  end

  module ClassMethods
    def cache(*attributes)
      attributes_to_cache = attributes.map(&:to_sym)
      self.attributes_to_cache = attributes_to_cache
    end

    def cache_ignore_diff(*attributes)
      attributes_to_ignore_on_diff = attributes.map(&:to_sym)
      self.attributes_to_ignore_on_diff = attributes_to_ignore_on_diff
    end

    protected

    def cache!
      CacheAttributes.new(self).call
    end
  end
end

ActiveSupport.on_load :active_record do
  include Cacheable
end
