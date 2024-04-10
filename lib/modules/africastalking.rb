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
  end

end