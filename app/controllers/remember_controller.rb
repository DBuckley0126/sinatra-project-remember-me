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

  post '/remember' do
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

end
