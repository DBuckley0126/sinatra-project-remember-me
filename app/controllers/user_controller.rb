class UserController < ApplicationController

  get '/signup' do
    flash[:error]
    flash[:alert]
    erb :'users/signup'
  end

  get '/user/link-alexa' do
    if Helpers.is_logged_in?(session)
      flash[:error]
      flash[:alert]
      erb :'users/link_alexa'
    else
      redirect '/signup'
    end
  end

  post '/user/link-alexa' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      if params[:unique_code] != ""
        if Helpers.link_user_to_alexa(@user, params[:unique_code])
          flash[:alert] = "Alexa account linked, all Remembers previously made with Alexa will now be accessible on this account."
          redirect '/'
        else
          flash[:error] = "Invalid Unique Code"
          redirect '/user/link-alexa'
        end
      else
        flash[:error] = "Must enter Unique Code"
        redirect '/user/link-alexa'
      end
    else
      redirect '/signup'
    end
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
      user.email_verified = false
      user.alexa_linked = false
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
      
      if @user && @user.authenticate(params[:password]) && @user.email_verified == true
        session["user_id"] = @user.id
        flash[:alert] = "You are logged in"
        redirect '/'
        
      elsif @user && @user.authenticate(params[:password]) && @user.email_verified == false
        Helpers.verififcation_email_send(@user)
        session[:email] =  @user.email
        flash[:error] = "Your email needs to be verified!"
        redirect '/user/email-verification'

      elsif @user && !@user.authenticate(params[:password])
        flash[:error] = "Your password is incorrect!"
        redirect '/login'
      end

      flash[:error] = "Your email can not be found!"
      redirect '/login'
    end
  end

  get '/user/email-verification' do
    if session[:email].nil?
      redirect '/login'
    elsif User.all.pluck(:email).include?(session[:email])
      flash[:alert]
      flash[:error]
      @email = session[:email]
      erb :'users/email_verification'
    else
      redirect '/login'
    end
  end

  post '/user/email-verification' do
    if session[:email].nil?
      redirect '/login'
    else
      if Helpers.email_temp_code_check(session[:email], params[:temp_code])
        user = User.find_by(email: session[:email])
        session[:email] = nil
        session[:user_id] = user.id
        redirect '/'
      else
        flash[:error] = "Wrong temporary code, please try again"
        redirect '/user/email-verififcation'
      end
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
      flash[:error]
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