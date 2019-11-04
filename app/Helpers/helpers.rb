class Helpers

  AMAZON_API_URL = "https://api.amazon.com/user/profile".freeze

  # Checks if user is logged in
  #
  # @param [Session] session is the current user session object
  #
  # @return [Boolean]
  #
  # @type [Boolean]
  def self.is_logged_in?(session)
    if session
      User.find_by_id(session["user_id"])? true : false
    else
      false
    end
  end


  # Returns current user
  #
  # @param [Session] session is the current user session object
  #
  # @return [User] returns User object
  #
  # @type [User]
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


  # Checks if email is valid format
  #
  # @param [String] email is a user email
  #
  # @return [Boolean]
  #
  # @type [Boolean]
  def self.check_email(email)
    email.match(/\A([\w+\-].?)+@[a-z\d\-]+(\.[a-z]+)*\.[a-z]+\z/i)? true : false
  end


  # Checks if email has been previously used in database
  #
  # @param [String] email is a user email
  #
  # @return [Boolean]
  #
  # @type [Boolean]
  def self.email_used?(email)
    User.find_by(email: email)? true : false
  end


  # Handles Alexa authentication
  #
  # @param [String] access_token is a user API access token sent with the Alexa HTTP request
  #
  # @return [Hash] returns a hash containing a history key with value explaining how account was created/linked. Also a user key with a User object
  #
  # @type [Hash]
  def self.auth_alexa(access_token)
    #method setup
    client = Net::HTTP
    uri = URI.parse("#{AMAZON_API_URL}?access_token=#{access_token}")
    first_name = JSON.parse(client.get(uri))["name"].split(" ").first
    last_name = JSON.parse(client.get(uri))["name"].split(" ").last
    email = JSON.parse(client.get(uri))["email"]

    #find alexa connected account > return found connected user
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
    else #make new user if no account has been found
      encrypted_temp_pass = Helpers.encrypt(Helpers.password_generator)
      new_user = User.create(first_name: first_name, last_name: last_name, email: email, access_token: access_token, password: encrypted_temp_pass)
      return {:history => "account created", :user => new_user}
    end
  end

  
  # Creates remember from Alexa request
  #
  # @param [Request] request is a object which is created from the Ralyxa gem once the html request is passed into the Ralyxa::Skill.handle
  #
  # @return [Remember] returns created Rememeber object
  #
  # @type [Remember]
  def self.add_alexa_remember(request)
    response = Helpers.auth_alexa(request.user_access_token)
    remember = Helpers.create_remember(response[:user], request.slot_value("phrase"), request.slot_value("answer"))
    remember
  end

  
  # Creates Remember
  #
  # @param [User] user is a user object
  # @param [String] phrase is a user phrase to invoke a answer
  # @param [String] answer is a user answer to be a response to a phrase
  #
  # @return [Remember] returns created Rememeber object
  #
  # @type [Remember]
  def self.create_remember(user, phrase, answer)
    remember = Remember.new(phrase: phrase.downcase, answer: answer.downcase)
    remember.user = user
    remember.save
    remember
  end

  
  # Fuzzy match a phrase to Rememebers in database
  # (will always return a result unless no words match)
  #
  # @param [String] phrase is a user phrase to invoke a answer
  # @param [User] user is a user object
  #
  # @return [Remember] returns matched remember object
  #
  # @type [Remember]
  def self.fuzzy_match_remember(phrase, user)
    fuzzy_object = FuzzyMatch.new(Remember.all.where(user: user), :read => :phrase, :must_match_at_least_one_word => true)
    fuzzy_object.find(phrase)
  end

  
  # Updates remember entity in database
  #
  # @param [Hash] params is the paramaters returned from the request
  # @param [Session] session is the current user session object
  #
  # @return [Remember] returns updated remember
  #
  # @type [Rememeber]
  def self.update_remember(params, session)
    user = Helpers.current_user(session)
    remember = Remember.find_by(user_id: user.id, id: params[:id])
    remember.phrase = params[:remember][:phrase].downcase
    remember.answer = params[:remember][:answer].downcase
    remember.save
    remember
  end

  def self.send_verification_email(user, temp_pass)
    variable = Mailjet::Send.create(messages: [{
      'From'=> {
        'Email'=> "rememberme.noreply@gmail.com",
        'Name'=> "Remember Me"
      },
      'To'=> [
        {
          'Email'=> user.email,
          'Name'=> "#{user.first_name} #{user.last_name}"
        }
      ],
      'TemplateID'=> 1070034,
      'TemplateLanguage'=> true,
      'Subject'=> "Remember Me Account Confirmation",
      'Variables'=> {
        "temp_password" => temp_pass
      }
    }])
    p variable.attributes['Messages']
  end

  def self.encrypt(string)
    Encryption.key = ENV['ENCRYPT_KEY']
    encrypted_str = Encryption.encrypt(string)
    encrypted_str
  end

  def self.decrypt(encrypted_string)
    Encryption.key = ENV['ENCRYPT_KEY']
    decrypted_data = Encryption.decrypt(encrypted_string)
    decrypted_data
  end

  def self.password_generator
    Passgen::generate
  end

end
