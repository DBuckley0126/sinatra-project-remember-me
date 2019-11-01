require 'active_support/core_ext/array/conversions'

intent "Remember" do

    return tell("Please autenticate Remember Me via the Alexa app by saying, Launch Remember Me") unless request.user_access_token_exists?

    Helpers.add_alexa_remember(request)

    tell("This has now been remembered")
end