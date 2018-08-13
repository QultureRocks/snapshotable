# frozen_string_literal: true

class PersonSnapshot < ApplicationRecord
  belongs_to :person

  validates :person, presence: true
  validates :attributes, presence: true
end
