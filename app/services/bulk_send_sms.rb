# Purpose: Send SMS to a phone number using Africa's Talking API
require './lib/modules/africastalking'

class BulkSendSms

  attr_reader :broadcast_message_id, :broadcast_message, :users, :phone_number, :success_count, :failure_count, :failure_reasons

  def initialize(params={})
    @broadcast_message_id = params[:broadcast_message_id] || params['broadcast_message_id']
    @success_count = 0
    @failure_count = 0
    @failure_reasons = []
  end

  def call
    puts '[Service] Bulk sending broadcast sms called..'

    load_broadcast_message
    load_users
    send_sms
    results
  end

  private

  def load_broadcast_message
    @broadcast_message = BroadcastMessage.find(broadcast_message_id)

    if broadcast_message.blank?
      puts 'No broadcast message found'
      return false
    end

    puts "Loaded broadcast message - #{broadcast_message.message}"
  end

  def load_users
    return if broadcast_message.blank?
    @users = User.all

    if users.empty?
      puts 'No users found'
      return false
    end

    puts "Loaded #{users.size} users"
  end




  def send_sms
    return if users.empty?

    users.each do |user|
      puts "Sending SMS to #{user.name} with phone - #{user.phone_number}"
      request = Africastalking.send_sms(
        message: Liquid::Template.parse(broadcast_message.message).render(
          "name" => user.name
        ),
        to: user.phone_number
      )

      puts request

      if request[0].status == 'Success'
        success_count += 1
        puts 'SMS sent successfully'
      else
        failure_count += 1
        puts 'Failed to send SMS'
        failure_reasons << "#{request[0].status} - #{request[0].number} for #{user.name}"
      end
    end
  end

  def results
    @broadcast_message.update(status: :sent)

    total_count = users.size
    puts "Successfully sent to #{success_count} out of #{total_count} users"
    puts "Failed to send to #{failure_count} users, reasons: #{failure_reasons.join(', ')}"
  end

end
