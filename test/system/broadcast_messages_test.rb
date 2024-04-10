require "application_system_test_case"

class BroadcastMessagesTest < ApplicationSystemTestCase
  setup do
    @broadcast_message = broadcast_messages(:one)
  end

  test "visiting the index" do
    visit broadcast_messages_url
    assert_selector "h1", text: "Broadcast messages"
  end

  test "should create broadcast message" do
    visit broadcast_messages_url
    click_on "New broadcast message"

    fill_in "Message", with: @broadcast_message.message
    click_on "Create Broadcast message"

    assert_text "Broadcast message was successfully created"
    click_on "Back"
  end

  test "should update Broadcast message" do
    visit broadcast_message_url(@broadcast_message)
    click_on "Edit this broadcast message", match: :first

    fill_in "Message", with: @broadcast_message.message
    click_on "Update Broadcast message"

    assert_text "Broadcast message was successfully updated"
    click_on "Back"
  end

  test "should destroy Broadcast message" do
    visit broadcast_message_url(@broadcast_message)
    click_on "Destroy this broadcast message", match: :first

    assert_text "Broadcast message was successfully destroyed"
  end
end
