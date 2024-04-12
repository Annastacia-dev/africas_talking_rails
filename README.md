# Integrating Africa's Talking (SMS) in your Rails Application

### Pre-requisites
- Knowledge of Ruby on Rails

### Setup
- To run this on your local, clone the repository and run `bundle install` to install all the dependencies.
- Run `rails db:create` to create the database and `rails db:migrate` to run the migrations.
- Run `rails db:seed` to seed the database with `users` data.
- Run `rails s` to start the server and navigate to `http://localhost:3000` to view the application.
- Generate a `master.key` file and add it to the `config` directory to access the credentials file and save your Africa's Talking API key and username.


#### Africa's Talking

- If you don't have an account, you can sign up [here](https://account.africastalking.com/auth/register)
- Follow the registration process and activate your account.
- By default AT( Africa's Talking) provides you with a sandbox account, you can use this to test your application.
- On the menu on your left, click on settings and click on API Key, enter your password and click on generate API key.
- This will generate an API key for your sandbox account, copy this key and keep it safe.
- Default username for sandbox account is `sandbox`

- For production, you need to first create a team, and within the team, you can create a new app. Give your app a name, username, select your country and currency then save.
- To get your API key, click on the app you just created, and click on settings, then click on API Key, enter your password and click on generate API key.

#### Rails Application

- In your Rails application, add the `africastalking-ruby` gem to your Gemfile and run `bundle install`
- You can add the key and username to your environment variables or to your credentials file.
- For this tutorial I'll be using the credentials file, to create a new credentials file, run `EDITOR="nano" rails credentials:edit` in your terminal.
- Add the following to your credentials file:

```yml
  africas_talking:
    sandbox_username: 'sandbox'
    sandbox_api_key: 'your_sandbox_api_key'
    prod_username: 'your_prod_username'
    prod_api_key: 'your_prod_api_key'
```

- Make sure to substitute `your_sandbox_api_key`, `your_prod_username` and `your_prod_api_key` with your actual keys.
- At this point, you can test if your credentials from the console, open your console and run the following:

```ruby
require 'AfricasTalking'

username = Rails.application.credentials.africas_talking[:sandbox_username]
api_key = Rails.application.credentials.africas_talking[:sandbox_api_key]

@AT=AfricasTalking::Initialize.new(username, api_key)

@AT.sms.send(to: '07xxxxxxxx', message => 'message')
```
NOTE
- If you use sandbox credentials, the message isn't actually sent to the phone number, it's just a simulation.You can use the [Launch a Simulator](https://developers.africastalking.com/simulator) feature on the AT dashboard to see the message. Enter the phone number you want to send the message to, connect then send the message from your console.

- A successful response should look lie this
```ruby
[#<StatusReport:0x00007fe8c9d47358
  @cost="KES 0.8000",
  @messageId="ATXid_e5b768b6d7bb4b5f45c4b40399fd1bab",
  @number="07xxxxxxxx",
  @status="Success"
>]
```
- A failure response might look like this
```ruby
[#<StatusReport:0x00007fe8c9e9b880
  @cost="0",
  @messageId="None",
  @number="7xxxxxxxx",
  @status="InvalidPhoneNumber"
>]
```
- For Kenyan numbers, the valid formats are `2547xxxxxxxx` or `07xxxxxxxx` or `+2547xxxxxxx`

#### Implementation

- In your Rails application, create a new file in the `config/initializers` directory and name it `africastalking.rb`
- Let's create an AT module which will handle all Africas Talking related tasks. Create a file in `lib/modules/africastalking.rb` and add the following:

```ruby
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

  def self.send_sms(**options)
    new.send_sms(args)
  end

  def send_sms(**options)
    message = options[:message]
    to = options[:to]

    @sms.send(
      'to' => to,
      'message' => message,
      'retryDurationInHours' => 1
    )
  end
end
```
- `message` and `to` are `REQUIRED` options while `retryDurationInHours` is optional, it specifies the number of hours for our message to be retried incase it's not delivered.
- Other optional arguments are `from` which is the senders ID ( by default it is  `'AFRICASTKNG'`) that you can register with Africa's Talking. To see what other options you can pass check [AT's Github Documentation](https://github.com/AfricasTalkingLtd/africastalking-ruby)
- We initialize the Africastalking class with the username and api key from our credentials file, we then create a new instance of the Africastalking class and call the send_sms method with the message and to options.

#### Usage

- In this example, I have set up a simple `User` model that only takes in a `name` and `phone_number` and a model `Broadcast Message` that has a `message` and a `status`. We will create a broadcast message and send it to all the users in our database.
- In my `broadcast_messages_controller.rb` (or wherever you want to send the message from), I'll define an action `send_sms` that will send the message to all the users in our database.This action will in turn call a service object that will handle sending the message to all the users in our database.

```ruby
def send_sms
  BulkSendSms.new(broadcast_message_id: @broadcast_message.id).call
end
```
- On the index page I list all the broadcast messages and have a button to send the message to all the users in the database.


- I have created a service object `BulkSendSms` that will handle sending the message to all the users in our database. Create a new file in `app/services` and name it `bulk_send_sms.rb` and add the following:

```ruby
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
```
- I initiate success_count, failure_count and failure_reasons to keep track of the number of messages sent successfully, the number of messages that failed to send and the reasons for the failure respectively.
- We then load the broadcast message and users from the database, if the broadcast message is not found or there are no users in the database, we return false.
- In the send_sms method, we loop through all the users in the database and send the message to each user. We use the Liquid gem to parse the message and render the user's name in the message.We then call the Africastalking send_sms method we defined earlier in the Africastalking module and pass in the message and the user's phone number.
- In the results method, we update the broadcast message status to sent and print out the number of messages sent successfully and the number of messages that failed to send and the reasons for the failure.Instead of logging you can create a report and send it to your email or the notifcation model or any other way you prefer.

#### Conclusion
- You can now send SMS to all the users in your database using Africas Talking API. You can also extend this to send SMS to a specific group of users or to send SMS to a single user. You can also add more options to the send_sms method to allow for more customization of the message.
- For improvements, we can use a worker to send the messages in the background to avoid blocking the main thread. We can also set up  webhooks to get delivery reports and handle failed messages.

You can find the full code [here](https://github.com/Annastacia-dev/africas_talking_rails)

Thank you for reading this tutorial, I hope you found it helpful. If you have any questions or suggestions, feel free to reach out to me on [Email](mailto:annetotoh@gmail.com) or [LinkedIn](https://www.linkedin.com/in/annastacia-mumbua)