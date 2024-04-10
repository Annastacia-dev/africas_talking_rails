json.extract! broadcast_message, :id, :message, :created_at, :updated_at
json.url broadcast_message_url(broadcast_message, format: :json)
