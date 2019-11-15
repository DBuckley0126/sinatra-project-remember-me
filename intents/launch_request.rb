require 'active_support/core_ext/array/conversions'

intent "LaunchRequest" do
  return tell("Please authenticate Remember Me via the Alexa app.", card: link_account_card) unless request.user_access_token_exists?

  response = Helpers.auth_alexa(request.user_access_token)
  user = response[:user]

  case response[:history]
  when "alexa connected account"
    ask("Welcome back #{user.first_name}, to Remember Me. What would you like to do this visit?")
  when "account linked"
    ask("Welcome, #{user.first_name} to Remember Me. Your existing Remember Me account has been linked. You can tell me to remember anything. For example, you can say ‘remember where I left my keys with the answer in the kitchen draw’. So when you are struggling to remember where your keys are, simply ask me ‘do you know where I left my keys’.")
  when "account created"
    ask("Welcome, #{user.first_name} to the Remember Me skill. You can ask me to Remember anything for you so when your struggling to remember a certain something, just ask me about it! An account has also been made and you can now login to the Remember Me website to visit your dashboard. Say 'help' for more infomation on how to use this skill.")
  end
end
