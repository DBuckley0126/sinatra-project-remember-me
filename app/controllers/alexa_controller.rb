class AlexaController < ApplicationController

  post '/' do
    Ralyxa::Skill.handle(request)
  end

end
