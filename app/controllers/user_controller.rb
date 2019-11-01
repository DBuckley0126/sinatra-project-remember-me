class UserController < ApplicationController

  get '/signup' do
    flash[:error]
    erb :'users/signup'
  end

  post '/signup' do
    if params.has_value?("")
      flash[:error] = "Not all inputs have been filled in!"
      redirect '/signup'

    elsif !Helpers.check_email(params[:email])
      flash[:error] = "Invalid Email!"
      redirect '/signup'   

    elsif Helpers.email_used?(params[:email])
      flash[:error] = "Email already in use!"
      redirect '/signup'

    else
      User.create(params)
      redirect '/login'
    end
  end

  get  '/login' do
    if Helpers.is_logged_in?(session)
      flash[:alert] = "You are already logged in"
      redirect '/'
    else
      flash[:alert]
      flash[:error]
      erb :'users/login' 
    end
  end

  post '/login' do
    if params.has_value?("")
      flash[:error] = "Not all inputs have been filled in!"
      redirect '/login'
    else
      @user = User.find_by(email: params[:email])
      
      if @user && @user.authenticate(params[:password])
        session["user_id"] = @user.id
        flash[:alert] = "You are logged in"
        redirect '/'
      end
      flash[:error] = "Your email or password can not be found!"
      redirect '/login'
    end
  end

  get '/logout' do
    if Helpers.is_logged_in?(session)
      session.clear
      flash[:alert] = "You have been logged out"
      redirect '/login'
    else
      redirect '/signup'
    end
  end
end