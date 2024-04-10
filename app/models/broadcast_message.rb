class BroadcastMessage < ApplicationRecord
  after_create_commit -> { broadcast_prepend_to "broadcast_messages" }
  after_update_commit -> { broadcast_replace_to "broadcast_messages" }
  after_destroy_commit -> { broadcast_remove_to "broadcast_messages" }

  validates :message, presence: true
end
