# frozen_string_literal: true

class TestModel < ApplicationRecord
  def self.load_schema!
    @columns_hash = {}
  end
  snapshot
end
