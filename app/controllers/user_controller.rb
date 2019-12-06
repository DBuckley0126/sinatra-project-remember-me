class UserController < ApplicationController

  get '/welcome' do
    flash[:error]
    flash[:alert]
    erb :'welcome', :layout => :welcome_layout
  end
  
  #vintage
  get '/signup' do
    flash[:error]
    flash[:alert]
    erb :'welcome', :layout => :welcome_layout
  end

  get '/user/account' do
    user_check(session)
    @user = Helpers.current_user(session)
    flash[:error]
    flash[:alert]
    erb :'users/account', :layout => :account_layout

  end

  post '/user/link-alexa' do
    user_check(session)
      @user = Helpers.current_user(session)
      if params[:unique_code] != ""
        if Helpers.link_user_to_alexa(@user, params[:unique_code])
          flash[:alert] = "Alexa account linked, all Remembers previously made with Alexa will now be accessible on this account."
          redirect '/user/account'
        else
          flash[:error] = "Invalid Unique Code"
          redirect '/user/account'
        end
      else
        flash[:error] = "Must enter Unique Code"
        redirect '/user/account'
      end
  end

  post '/signup' do
    if params.has_value?("")
      flash[:error] = "Not all inputs have been filled in!"
      redirect '/welcome'

    elsif !Helpers.check_email(params[:email])
      flash[:error] = "Invalid Email!"
      redirect '/welcome'   

    elsif Helpers.email_used?(params[:email])
      flash[:error] = "Email already in use!"
      redirect '/welcome'

    else
      user = User.create(params)
      user.email_verified = false
      user.alexa_linked = false
      user.save
      session[:email] =  user.email
      Helpers.verififcation_email_send(user)
      flash[:error] = "Your email needs to be verified!"
      redirect '/user/email-verification'
    end
  end

  post '/login' do
    if params.has_value?("")
      flash[:error] = "Not all inputs have been filled in!"
      redirect '/welcome'
    else
      @user = User.find_by(email: params[:email])
      
      if @user && @user.authenticate(params[:password]) && @user.email_verified == true
        session["user_id"] = @user.id
        redirect '/'
        
      elsif @user && @user.authenticate(params[:password]) && @user.email_verified == false
        Helpers.verififcation_email_send(@user)
        session[:email] =  @user.email
        flash[:error] = "Your email needs to be verified!"
        redirect '/user/email-verification'

      elsif @user && !@user.authenticate(params[:password])
        flash[:error] = "Your password is incorrect!"
        redirect '/welcome'
      end

      flash[:error] = "Your email can not be found!"
      redirect '/welcome'
    end
  end

  get '/user/email-verification' do
    if session[:email].nil?
      redirect '/welcome'
    elsif User.all.pluck(:email).include?(session[:email])
      flash[:alert]
      flash[:error]
      @email = session[:email]
      erb :'users/email_verification', :layout => :'welcome_layout'
    else
      redirect '/welcome'
    end
  end

  post '/user/email-verification' do
    if session[:email].nil?
      redirect '/welcome'
    else
      if Helpers.email_temp_code_check(session[:email], params[:temp_code])
        user = User.find_by(email: session[:email])
        session[:email] = nil
        session[:user_id] = user.id
        redirect '/'
      elsif params[:temp_code] == ""
        flash[:error] = "Please input temporary code"
        redirect '/user/email-verification'
      else
        flash[:error] = "Incorrect temporary code, please try again"
        redirect '/user/email-verification'
      end
    end
  end

  post '/user/email-verification-resend' do
    if session[:email].nil?
      redirect '/welcome'
    else
      @user = User.find_by(email: session[:email])
      Helpers.verififcation_email_send(@user)
      flash[:alert] = "Email verification email sent"
      redirect '/user/email-verification'
    end
  end

  get '/logout' do
    if Helpers.is_logged_in?(session)
      session.clear
      redirect '/welcome'
    else
      redirect '/welcome'
    end
  end

  patch '/user/password-reset' do
    user_check(session)
      user = Helpers.current_user(session)

      if params.has_value?("")
        flash[:alert] = "Please complete all inputs to reset password"
        redirect '/user/account'

      elsif user && user.authenticate(params["info"]["old_password"])
        
        Helpers.update_password(params, session)
        flash[:alert] = "Updated password"
        redirect '/account'

      else
        flash[:alert] = "Current password entered incorrectly"
        redirect '/user/account'
      end
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