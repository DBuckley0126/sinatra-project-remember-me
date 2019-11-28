require 'active_support/core_ext/array/conversions'

intent "LaunchRequest" do

  response = Helpers.auth_alexa(request.user_id)

  case response[:history]
  when "alexa connected account"
    ask("Welcome back to Remember Me. What would you like to do this visit?")
  when "account created"
    ask("Welcome to the Remember Me skill, you can ask me to Remember anything for you! You can make an account on the Remember Me website to view and edit your Remembers. Say 'help' for more infomation on how to use this skill.")
  end
end
