class User < ActiveRecord::Base

  has_secure_password
  has_many :remembers
  serialize :temp_code
  serialize :vector

  def alexa_say_unique_code
    output = ""
    self.unique_code.split('').each do |char|
      output += char
      output += ".. "
    end
    output
  end

end