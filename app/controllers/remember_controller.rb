class RememberController < ApplicationController

  get '/remembers/new' do
    user_check(session)
    erb :'remembers/new'
  end

  post '/remembers' do
    user_check(session)
    @user = Helpers.current_user(session)
    Helpers.create_remember(@user, params[:phrase], params[:answer])
    redirect '/'
  end

  get '/remembers/:id/edit' do
    user_check(session)
    @user = Helpers.current_user(session)
    @remember = Remember.find_by(user_id: @user.id, id: params[:id])
    erb :'/remembers/edit'
  end

  get '/remembers/:id' do
    user_check(session)
    @user = Helpers.current_user(session)
    @remember = Remember.find_by(user_id: @user.id, id: params[:id])
    flash[:alert]
    erb :'remembers/view'
  end

  delete '/remembers/:id' do
    user_check(session)
    @user = Helpers.current_user(session)
    @remember = Remember.find_by(user_id: @user.id, id: params[:id])
    @remember.destroy
    flash[:alert] = "Deleted Remember"
    redirect '/'
  end
  
  patch '/remembers/:id' do
    user_check(session)
    remember = Helpers.update_remember(params, session)
    flash[:alert] = "Updated Remember"
    redirect "/remembers/#{remember.id}"
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
