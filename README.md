# Integrating Africas Talking (Bulk SMS) in your Rails Application

### Setup

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


