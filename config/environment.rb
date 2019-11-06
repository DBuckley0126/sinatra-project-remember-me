ENV['SINATRA_ENV'] ||= "development"

require 'bundler/setup'
Bundler.require(:default, ENV['SINATRA_ENV'])

db_config = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(db_config['production'])


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













