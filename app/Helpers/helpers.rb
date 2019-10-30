class Helpers
  def is_logged_in?(session)
    User.find_by_id(session[:user_id])? true : false
  end

  def current_user(session)
    @user = User.find_by_id(session[:user_id])
    if @user
      @user
    else
      begin
        raise ArgumentError.new("Unable to find user from session[:user_id]")
      rescue ArgumentError => e
        puts e.message
      end
    end
  end
end
