class CacheAttributes
  def initialize(record)
    @record = record
  end

  def call
    {
      cache: cache_attrs
    }
  end

  private

  attr_reader :record

  def cache_attrs
    extract_attributes(record.attributes_to_cache, record)
  end

  def extract_attributes(attributes, model)
    return {} if model.blank?

    attributes.inject({}) do |collected_attrs, attr|
      collected_attrs.merge(attr => model.send(attr))
    end
  end
end
