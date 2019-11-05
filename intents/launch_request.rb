require 'active_support/core_ext/array/conversions'

intent "LaunchRequest" do
  return tell("Please autenticate Remember Me via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?

  response = Helpers.auth_alexa(request.user_access_token)
  user = response[:user]

  case response[:history]
  when "alexa connected account"
    ask("Welcome back #{user.first_name}, to Remember Me")
  when "account linked"
    ask("Welcome, #{user.first_name} to Remember Me. Your existing account has been linked")
  when "account created"
    ask("Welcome, #{user.first_name} to Remember Me. An account has been made for you. You can login to the website to visit your dashboard")
  end
end
