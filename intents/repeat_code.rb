require 'active_support/core_ext/array/conversions'

intent "Repeat_Code" do

  user = Helpers.auth_alexa(request.user_id)[:user]

  if user.alexa_linked == true
    tell("Your Rememeber Me account has already been linked")
  else
    ask("Your unique code is #{user.alexa_say_unique_code} All letters are lowercase. If you would like me to repeat the code, say 'repeat code'.")
  end
end

