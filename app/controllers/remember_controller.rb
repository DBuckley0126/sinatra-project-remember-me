class RememberController < ApplicationController

  get '/remembers' do
    if Helpers.is_logged_in?(session)
    @user = Helpers.current_user(session)
    @remembers = Remember.where(user_id: @user.id)
    erb :'remembers/remembers'
    else
      redirect '/signup'
    end
  end

  get '/remembers/new' do
    if Helpers.is_logged_in?(session)
      erb :'remembers/new'
    else
      redirect '/signup'
    end
  end

  post '/remembers' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      @remember = Remember.new(params)
      @remember.user = @user
      @remember.save
      redirect '/remembers'
    else
      redirect '/signup'
    end
  end

  get '/remembers/:id/edit' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      @remember = Remember.find_by(user_id: @user.id, id: params[:id])
      erb :'/remembers/edit'
    else
      redirect '/signup'
    end
  end

  get '/remembers/:id' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      @remember = Remember.find_by(user_id: @user.id, id: params[:id])
      erb :'remembers/view'
    else
      redirect '/signup'
    end
  end

  delete '/remembers/:id' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      @remember = Remember.find_by(user_id: @user.id, id: params[:id])
      @remember.destroy
      redirect '/remembers'
    else
      redirect '/signup'
    end
  end

  patch '/remembers/:id' do
    if Helpers.is_logged_in?(session)
      @user = Helpers.current_user(session)
      @remember = Remember.find_by(user_id: @user.id, id: params[:id])
      @remember.update(params["remember"])
      redirect "/remembers/#{@remember.id}"
    else
      redirect '/signup'
    end
  end

end
