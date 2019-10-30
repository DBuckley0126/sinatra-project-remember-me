class UserController < ApplicationController

  get '/signup' do
    erb :'users/signup'
  end

  post '/signup' do
    if params.has_value?("")
      redirect '/signup'
    else
      User.create(params)
      redirect '/login'
    end
  end

  get  '/login' do
    if Helpers.is_logged_in?(session)
      redirect '/'
    else
      erb :'users/login'
    end
  end

  post '/login' do
    if params.has_value?("")
      redirect '/login'
    else
      @user = User.find_by(username: params[:username])
      
      if @user && @user.authenticate(params[:password])
        session["user_id"] = @user.id
        redirect '/'
      end

      redirect '/login'
    end
  end

  get '/logout' do
    if Helpers.is_logged_in?(session)
      session.clear
      redirect '/login'
    else
      redirect '/signup'
    end
  end
end