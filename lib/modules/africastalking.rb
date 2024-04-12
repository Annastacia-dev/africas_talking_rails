require 'AfricasTalking'

class Africastalking
  def initialize
    if Rails.env.production?
      username = Rails.application.credentials.africas_talking[:prod_username]
      api_key = Rails.application.credentials.africas_talking[:prod_api_key]
    else
      username = Rails.application.credentials.africas_talking[:sandbox_username]
      api_key = Rails.application.credentials.africas_talking[:sandbox_api_key]
    end
    at = AfricasTalking::Initialize.new(username, api_key)
    @sms = at.sms
    byebug
  end

  def self.send_sms(**options)
    new.send_sms(**options)
  end

  def send_sms(**options)
    message = options[:message]
    to = options[:to]

    @sms.send(
      'from' => '1644',
      'to' => to,
      'message' => message,
      'retryDurationInHours' => 1
    )
  end
end