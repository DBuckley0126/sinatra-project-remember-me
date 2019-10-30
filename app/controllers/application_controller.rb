require './config/environment'

class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, Proc.new { File.join(root, "../views/") }
    register Sinatra::ActiveRecordExtension
    set :session_secret, "my_application_secret"
  end

  get "/" do
    erb :welcome
    
  end

end
