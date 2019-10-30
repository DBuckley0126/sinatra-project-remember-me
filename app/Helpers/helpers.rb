class Helpers
  def self.is_logged_in?(session)
    if session
      User.find_by_id(session["user_id"])? true : false
    else
      false
    end
  end

  def self.current_user(session)
    @user = User.find_by_id(session["user_id"])
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

  def self.check_email(email)
    if email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
      true
    else
      false
    end
  end

  def self.email_used?(email)
    if User.find_by(email: email)
      true
    else
      false
    end
  end

  def self.username_used?(username)
    if User.find_by(username: username)
      true
    else
      false
    end
  end

end
