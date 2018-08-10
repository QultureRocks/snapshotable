class <%= migration_class_name %> < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :<%= model_underscored %>_snapshots do |t|
      # model to be snapshoted
      t.references :<%= model_underscored %>, index: true, null: false, foreign_key: true

      # snapshoted_attributes
      t.jsonb :attributes, null: false
<% relations_has_one.each do |relation| %>
      t.jsonb :<%= relation.underscore %>_attributes, null: false<% end %>
<% relations_has_many.each do |relation| %>
      t.jsonb :<%= relation.underscore %>_attributes, null: false, array: true, default: []<% end %>

      t.timestamps null: false
    end
  end
end