source 'http://rubygems.org'

ruby '2.4.1'

gem 'sinatra'
gem 'activerecord', '~> 4.2', '>= 4.2.6', :require => 'active_record'
gem 'sinatra-activerecord', :require => 'sinatra/activerecord'
gem 'rake'
gem 'require_all'
gem 'thin'
gem 'shotgun'
gem 'pry'
gem 'bcrypt'
gem 'tux'
gem 'sinatra-flash'
gem 'ralyxa'
gem 'activesupport'
gem 'fuzzy_match', '~> 2.1'
gem 'mailjet'
gem 'encryption'
gem 'cryptice-passgen', '~> 0.1.2'
gem 'puma'
gem "barnes"

group :development do
  gem 'sqlite3', '~> 1.3.6'
 end

 group :test do
  gem 'rspec'
  gem 'capybara'
  gem 'rack-test'
  gem 'database_cleaner', git: 'https://github.com/bmabey/database_cleaner.git'
end
 
group :production do
  gem 'pg', '~> 0.18'
end