require './config/environment'


class ApplicationController < Sinatra::Base

  configure do
    set :public_folder, 'public'
    set :views, Proc.new { File.join(root, "../views/") }
    register Sinatra::ActiveRecordExtension
    enable :sessions
    set :session_secret, ENV['SESSION_SECRET']
    register Sinatra::Flash

    Mailjet.configure do |config|
      config.api_key = ENV['MJ_APIKEY_PUBLIC']
      config.secret_key = ENV['MJ_APIKEY_PRIVATE']
      config.api_version = "v3.1"
    end
    
  end

  get "/" do
    user_check(session)
    @user = Helpers.current_user(session)
    @remembers = Remember.where(user_id: @user.id)
    flash[:alert]
    flash[:error]
    erb :'index'
  end


  get '/terms-of-use' do
    erb :'terms/terms_of_use'
  end

  
  get '/privacy-policy' do
    erb :'terms/privacy_policy'
  end

  private

  def user_check(session)
    result = Helpers.is_logged_in?(session)

    if result == "GOOD"
      true
    elsif result == "UNVERIFIED"
      flash[:error] = "Your email needs to be verified!"
      redirect '/user/email-verification'
    else
      redirect '/welcome' if ENV['SINATRA_ENV'] == "development"
      redirect 'https://www.myremember.co.uk/welcome'
    end
  end



end