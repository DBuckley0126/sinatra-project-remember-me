class AlexaController < ApplicationController

  post '/' do
    Ralyxa::Skill.handle(request)
  end

  get '/alexa-email' do
    flash[:error]
    erb :'alexa/email'
  end

  post '/alexa-email' do
    if !Helpers.email_used?(params[:email])
      flash[:error] = "There is no account with this email"
      redirect '/signup'
    elsif Helpers.alexa_email_verified_check(params[:email])
      flash[:error] = "Account already verified"
      redirect '/login'
    else
      session["email"] = params[:email]
      Helpers.alexa_temp_password_send(params[:email])
      redirect '/alexa-verify'
    end
  end

  get '/alexa-verify' do
    if session["email"]
      flash[:error]
      @email = session["email"]
      erb :'alexa/verify'
    else
      flash[:error] = "Please type your alexa email here"
      redirect '/alexa-email'
    end
  end

  post '/alexa-verify' do
    if session["email"]
      user = Helpers.alexa_temp_password_check(session["email"], params[:temp_password])
      if user
        session["user_id"] = user.id
        redirect '/user/password-reset'
      else
        flash[:error] = "Wrong temporary passord, please try again"
        redirect '/alexa-verify'
      end
    else
      flash[:error] = "Please type your alexa email here"
      redirect '/alexa-email'
    end
  end

end