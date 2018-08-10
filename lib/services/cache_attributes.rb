module CacheableModels
  class CacheAttributes
    def initialize(record)
      @record = record
    end

    def call
      cache_attrs
    end

    private

    attr_reader :record

    def cache_attrs
      cached_attributes = {}

      cached_attributes[:cache] = extract_attributes(record_cached_attrs, record) if record_cached_attrs.any?

      deep_cached_attrs&.each do |association_name, attributes|
        association = record.send(association_name)

        cached_attributes["#{association_name}_cache"] = if association.class.name == 'ActiveRecord::Associations::CollectionProxy'
                                                           association.map { |model| extract_attributes(attributes, model) }
                                                         else
                                                           extract_attributes(attributes, association)
                                                         end
      end

      cached_attributes
    end

    def extract_attributes(attributes, model)
      return {} if model.blank?

      attributes.inject({}) do |collected_attrs, attr|
        collected_attrs.merge(attr => model.send(attr))
      end
    end

    def record_cached_attrs
      @record_cached_attrs ||= record.attributes_to_cache.select { |attr| attr.is_a? Symbol }
    end

    def deep_cached_attrs
      @deep_cached_attrs ||= record.attributes_to_cache.select { |attr| attr.is_a? Hash }.first
    end
  end
end
