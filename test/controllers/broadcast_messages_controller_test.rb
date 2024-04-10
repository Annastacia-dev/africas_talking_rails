require "test_helper"

class BroadcastMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @broadcast_message = broadcast_messages(:one)
  end

  test "should get index" do
    get broadcast_messages_url
    assert_response :success
  end

  test "should get new" do
    get new_broadcast_message_url
    assert_response :success
  end

  test "should create broadcast_message" do
    assert_difference("BroadcastMessage.count") do
      post broadcast_messages_url, params: { broadcast_message: { message: @broadcast_message.message } }
    end

    assert_redirected_to broadcast_message_url(BroadcastMessage.last)
  end

  test "should show broadcast_message" do
    get broadcast_message_url(@broadcast_message)
    assert_response :success
  end

  test "should get edit" do
    get edit_broadcast_message_url(@broadcast_message)
    assert_response :success
  end

  test "should update broadcast_message" do
    patch broadcast_message_url(@broadcast_message), params: { broadcast_message: { message: @broadcast_message.message } }
    assert_redirected_to broadcast_message_url(@broadcast_message)
  end

  test "should destroy broadcast_message" do
    assert_difference("BroadcastMessage.count", -1) do
      delete broadcast_message_url(@broadcast_message)
    end

    assert_redirected_to broadcast_messages_url
  end
end
