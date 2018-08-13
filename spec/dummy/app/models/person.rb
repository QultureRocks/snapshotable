# frozen_string_literal: true

class Person < ApplicationRecord
  has_one :mother
  has_one :father
  has_and_belongs_to_many :houses

  snapshot :name, :role, :bastard, mother: [:name, :role], father: [:name, :role], houses: [:name]
end
