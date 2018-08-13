FactoryBot.define do
  factory :person_snapshot do
    person
    object { { id: person.id } }
  end
end
