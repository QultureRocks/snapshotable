class CreatePerson < ActiveRecord::Migration[5.0]
  def change
    create_table :people do |t|
      t.references :father, index: true, foreign_key: { to_table: :people }
      t.references :mother, index: true, foreign_key: { to_table: :people }

      t.string :name
      t.string :role
      t.boolean :bastard
    end
  end
end
