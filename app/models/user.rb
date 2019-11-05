class User < ActiveRecord::Base

  has_secure_password
  has_many :remembers
  serialize :temp_password
  serialize :vector

end