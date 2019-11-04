require './config/environment'


class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, Proc.new { File.join(root, "../views/") }
    register Sinatra::ActiveRecordExtension
    enable :sessions
    #set :session_secret, "my_application_secret"
    set :session_secret, ENV['SESSION_SECRET']
    register Sinatra::Flash

    

    Mailjet.configure do |config|
      config.api_key = ENV['MJ_APIKEY_PUBLIC']
      config.secret_key = ENV['MJ_APIKEY_PRIVATE']
      config.api_version = "v3.1"
    end
    

  end

  get "/" do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      Helpers.test
      #binding.pry
      flash[:alert]
    erb :index
    else
      redirect '/signup'
    end
  end

end