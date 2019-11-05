require 'active_support/core_ext/array/conversions'

intent "Remember" do

    return tell("Please autenticate Remember Me via the Alexa app by saying, Launch Remember Me") unless request.user_access_token_exists?

    if request.slot_value("confimation") == "no"
        tell("This has not been remembered")
    else
        Helpers.add_alexa_remember(request)
        tell("This has now been remembered")
    end
end