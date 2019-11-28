require 'active_support/core_ext/array/conversions'

intent "Remember" do


    if request.slot_value("confimation") == "no"
        tell("This has not been remembered")
    else
        Helpers.add_alexa_remember(request)
        tell("This has now been remembered")
    end
end