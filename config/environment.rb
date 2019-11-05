ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database => "db/#{ENV['SINATRA_ENV']}.sqlite"
)

require 'pry'
require 'sinatra/flash'
require 'json'
require 'ralyxa'
require 'net/http'
require 'fuzzy_match'
require 'mailjet'
require 'openssl'
require 'passgen'


require './app/controllers/application_controller'
require_all 'app'













