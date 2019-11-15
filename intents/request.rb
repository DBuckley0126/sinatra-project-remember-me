require 'active_support/core_ext/array/conversions'

intent "Request" do

    return tell("Please authenticate Remember Me via the Alexa app by saying, Launch Remember Me") unless request.user_access_token_exists?
    remember_object = Helpers.fuzzy_match_remember(request.slot_value("phrase"), Helpers.auth_alexa(request.user_access_token)[:user])
    
    if remember_object
        tell("#{remember_object.answer}.")
    else
        tell("Remember me does not know anything about #{request.slot_value("phrase")}.")
    end

end