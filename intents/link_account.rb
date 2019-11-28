require 'active_support/core_ext/array/conversions'

intent "Link_Account" do

  user = Helpers.auth_alexa(request.user_id)[:user]

  if user.alexa_linked == true
    tell("Your Rememeber Me account has already been linked")
  else
    ask("Your unique code is #{user.alexa_say_unique_code} All letters are lowercase. Please go to www.my remember.co.uk and signup or login to an existing account. Once logged in, click the 'link alexa' button to enter your unique code. If you would like me to repeat the code, say 'repeat code'.")
  end
end

