# frozen_string_literal: true

require 'snapshotable/snapshots'

module Snapshotable
  class << self
    # Switches Snapshotable on or off
    def enabled=(value)
      Snapshotable.config.enabled = value
    end

    # Returns if Snapshotable is turned on
    def enabled?
      Snapshotable.config.enabled.present?
    end
  end
end

ActiveSupport.on_load :active_record do
  include Snapshotable::Model
end
