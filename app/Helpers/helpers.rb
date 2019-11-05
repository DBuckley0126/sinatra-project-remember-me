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
      new_user = User.create(first_name: first_name, last_name: last_name, email: email, access_token: access_token, password: Helpers.password_generator, verified: false)
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

  # Sends a verification email
  #
  # @param [User] user is a User Object
  # @param [String] temp_pass is the temporary password to be sent with the email
  #
  # @return [Hash] Returns hash of message attributes
  #
  # @type [Hash]
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

  # Encrypts a string using AES265 standard
  # This method requires a 16 byte key set with a local ENVIROMENT variable
  #
  # @param [String] string is the string that will be encrypted
  #
  # @return [Hash] returns hash with encrypted string and the randomly generated vector key
  #
  # @type [Hash]
  def self.encrypt(string) 
    cipher = OpenSSL::Cipher::AES256.new :CBC
    cipher.encrypt
    iv = cipher.random_iv
    cipher.key = ENV['ENCRYPT_KEY']

    cipher_text = cipher.update(string) + cipher.final
    {"encrypted_string" => cipher_text, "vector" => iv}
  end

  # Decrypts a string using AES256 standard
  #
  # @param [String] encrypted_string is the encrypted string
  # @param [String] iv is the vector key that was used to encrypt the string
  #
  # @return [String] returns the decrypted string
  #
  # @type [String]
  def self.decrypt(encrypted_string, iv) 
    decipher = OpenSSL::Cipher::AES256.new :CBC
    decipher.decrypt
    decipher.iv = iv
    decipher.key = ENV['ENCRYPT_KEY']

    decipher_text = decipher.update(encrypted_string) + decipher.final
    decipher_text
  end

  # Generates random password
  #
  # @return [String] returns randomly generated password
  #
  def self.password_generator 
    Passgen::generate
  end

  # Checks if provided email has already been veriefied
  #
  # @param [String] email is the email the user provided
  #
  # @return [Boolean]
  #
  # @type [Boolean]
  def self.alexa_email_verified_check(email) 
    User.find_by(email: email, verified: true)? true : false
  end

  # Sends temporary password email
  #
  # @param [String] email is the email the user provided
  #
  def self.alexa_temp_password_send(email) 
    user = User.find_by(email: email, verified: false)
    temp_pass = Helpers.password_generator
    encryption_hash = Helpers.encrypt(temp_pass)
    user.password = temp_pass
    user.temp_password = encryption_hash["encrypted_string"]
    user.vector = encryption_hash["vector"]
    user.save
    Helpers.send_verification_email(user, temp_pass)
  end

  # Checks if temporary password matches on in database
  #
  # @param [String] email is the email the user provided 
  # @param [String] temp_password is the temporary password the user provided
  #
  # @return [User, Boolean] returns a User object if temporary password matches and 
  # returns false if temporary password does not match one in datbase
  #
  # @type [User, Boolean]
  def self.alexa_temp_password_check(email, temp_password) 
    user = User.find_by(email: email, verified: false)
    decrypted_temp_pass = Helpers.decrypt(user.temp_password, user.vector)
    if decrypted_temp_pass == temp_password
      user.verified = true
      user.temp_password = ""
      user.save
      user
    else
      false
    end
  end

  # Updates users password
  #
  # @param [Hash] params is the params conatined within the request
  # @param [Hash] session is the current session accosiated with the user
  #
  def self.update_password(params, session) 
    user = Helpers.current_user(session)
    if user && user.authenticate(params["info"]["old_password"])
      user.password = params["user"]["password"]
      user.save
    end
  end

end
