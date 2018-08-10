class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= snapshotable_model %>_snapshots do |t|
      # model to be snapshoted
      t.references :<%= snapshotable_model %>, index: true, null: false, foreign_key: true

      # snapshoted_attributes
      t.jsonb :attributes, null: false
<% has_one.each do |relation| %>
      t.jsonb :<%= relation %>_attributes, null: false<% end %>
<% has_many.each do |relation| %>
      t.jsonb :<%= relation %>_attributes, null: false, array: true, default: []<% end %>

      t.timestamps null: false
    end
  end
end