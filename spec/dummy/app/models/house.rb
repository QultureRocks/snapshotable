# frozen_string_literal: true

class House < ApplicationRecord
  has_and_belongs_to_many :people
end
