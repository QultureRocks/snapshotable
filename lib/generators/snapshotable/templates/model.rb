class <%= model_camelcased %>Snapshot < <%= active_record_class %>
  belongs_to :<%= model_underscored %>

  validates :<%= model_underscored %>, presence: true
  validates :object, presence: true
end
