class Helpers

  AMAZON_API_URL = "https://api.amazon.com/user/profile".freeze

  def self.is_logged_in?(session) #returns boollean if user is logged in
    if session
      User.find_by_id(session["user_id"])? true : false
    else
      false
    end
  end

  def self.current_user(session) #returns user object
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

  def self.check_email(email) #returns true if email is valid
    if email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)
      true
    else
      false
    end
  end

  def self.email_used?(email) #returns true if email is unique in database
    if User.find_by(email: email)
      true
    else
      false
    end
  end

  def self.username_used?(username) #returns true if username is unique in database
    if User.find_by(username: username)
      true
    else
      false
    end
  end

  def self.auth_alexa(access_token, client = Net::HTTP) #returns hash from alexa access token which contains user object and history of account
    uri = URI.parse("#{AMAZON_API_URL}?access_token=#{access_token}")
    first_name = JSON.parse(client.get(uri))["name"].split(" ").first
    last_name = JSON.parse(client.get(uri))["name"].split(" ").last
    email = JSON.parse(client.get(uri))["email"]

    #find alexa connected account
    user = User.find_by(access_token: access_token)
    return {:history => "alexa connected account", :user => user} if user

    #find previously made account without alexa auth
    user = User.find_by(email: email)

    if user
      user.access_token = access_token
      user.first_name = first_name
      user.last_name = last_name
      user.save
      return {:history => "account linked", :user => user}
    else
      #make new user if no account has been found
      new_user = User.create(first_name: first_name, last_name: last_name, email: email, access_token: access_token, password: "SET")
      return {:history => "account created", :user => new_user}
    end
  end

  def self.add_alexa_remember(request) #returns created remember object from alexa request
    response = Helpers.auth_alexa(request.user_access_token)
    remember = Helpers.create_remember(response[:user], request.slot_value("phrase"), request.slot_value("answer"))
    remember
  end

  def self.create_remember(user, phrase, answer) #returns created remember object from user object, phrase string and answer string
    remember = Remember.new(phrase: phrase.downcase, answer: answer.downcase)
    remember.user = user
    remember.save
    remember
  end

  def self.fuzzy_match_remember(phrase, user) #returns remember object from phrase string and user object using fuzzy search (will always return an answer unless no words match)
    fuzzy_object = FuzzyMatch.new(Remember.all.where(user: user), :read => :phrase, :must_match_at_least_one_word => true)
    fuzzy_object.find(phrase)
  end



end
