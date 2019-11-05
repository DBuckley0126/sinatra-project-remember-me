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
      user = User.create(params)
      user.verified = 1
      user.save
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
        
      elsif @user && @user.verified == false
        flash[:error] = "Your account needs to be verified!"
        redirect '/login'

      elsif @user && !@user.authenticate(params[:password])
        flash[:error] = "Your password is incorrect!"
        redirect '/login'
      end

      flash[:error] = "Your email can not be found!"
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

  get '/user/password-reset' do
    if Helpers.is_logged_in?(session)
      flash[:alert]
      @user = Helpers.current_user(session)
      erb :'users/password_reset'

    else
      redirect '/signup'
    end
  end

  patch '/user/password-reset' do
    if Helpers.is_logged_in?(session)
      user = Helpers.current_user(session)

      if params.has_value?("")
        flash[:alert] = "Please complete all inputs"
        redirect '/user/password-reset'

      elsif user && user.authenticate(params["info"]["old_password"])
        
        Helpers.update_password(params, session)
        flash[:alert] = "Updated password"
        redirect '/'

      else
        flash[:alert] = "Current password entered incorrectly"
        redirect '/user/password-reset'
      end

    else
      redirect '/signup'
    end
  end


end