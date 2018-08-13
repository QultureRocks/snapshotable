class CreateHousesPeople < ActiveRecord::Migration[5.0]
  def change
    create_table :houses_people do |t|
      t.references :person, index: true, foreign_key: true
      t.references :house, index: true, foreign_key: true
    end

    add_index(:houses_people, [:person_id, :house_id], unique: true)
  end
end
