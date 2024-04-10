class CreateBroadcastMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :broadcast_messages do |t|
      t.text :message

      t.timestamps
    end
  end
end
