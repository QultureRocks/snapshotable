class CreatePersonSnapshots < ActiveRecord::Migration[5.0]
  def change
    create_table :person_snapshots do |t|
      # model to be snapshoted
      t.references :person, index: true, null: false, foreign_key: true

      # snapshoted_attributes
      t.jsonb :object, null: false

      t.jsonb :father_object
      t.jsonb :mother_object

      t.jsonb :houses_object, array: true, default: []

      t.timestamps null: false
    end
  end
end