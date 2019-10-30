class RememberController < ApplicationController

  get '/remembers' do
    if Helpers.is_logged_in?(session)
    @user = Helpers.current_user(session)
    @remembers = Remember.where(user_id: @user.id)
    flash[:alert]
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
      flash[:alert] = "Created new Remember"
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
      flash[:alert]
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
      flash[:alert] = "Deleted Remember"
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
      flash[:alert] = "Updated Remember"
      redirect "/remembers/#{@remember.id}"
    else
      redirect '/signup'
    end
  end

end
