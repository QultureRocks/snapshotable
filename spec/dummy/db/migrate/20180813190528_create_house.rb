class CreateHouse < ActiveRecord::Migration[5.0]
  def change
    create_table :houses do |t|
      t.string :name
    end
  end
end
