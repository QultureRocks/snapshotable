# frozen_string_literal: true

class Person < ApplicationRecord
  has_one :mother, class_name: Person.name, foreign_key: 'mother_id'
  has_one :father, class_name: Person.name, foreign_key: 'father_id'
  has_and_belongs_to_many :houses

  snapshot :name, :role, :bastard, mother: [:name, :role], father: [:name, :role], houses: [:name]
end
