class AddStatusToBroadCastMessage < ActiveRecord::Migration[7.1]
  def change
    add_column :broadcast_messages, :status, :integer, default: 0
  end
end
