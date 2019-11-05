# sinatra-project-remember-me

A Sinatra web application to help you to remember the little things in life with a simple phrase and answer This will also have a Alexa interface to interact with the service.  

Where did I leave my keys?  
What time did I walk the dog?  
What date is my doctor appointment?  
Who do I need to write a birthday card for this month?  
When did I last check my car oil level?  

Remember anything with **Remember Me!**

## Getting Started

Clone or download the repository to your local machine and after open your terminal on the repo and run:  

bundle install  
rake db:migrate  

run 'shotgun' in terminal to begin local hosting of Sinatra application.  
Use Ngrok to tunnel data to local server for Alexa requests.  


### Enviroment Variables

#### General application variables

**SESSION_SECRET=** Random long key  
**ENCRYPT_KEY=** 16 byte encryption key that Cipher used to encrypt AES256 standard  

#### To intergrate Alexa and Mailjet variables

**MJ_APIKEY_PUBLIC=** This is your Mailjet public API key  
**MJ_APIKEY_PRIVATE=** This is your Mailjet public API key  
**export FROM_EMAIL=** This is the email address that Mailjet will send emails from  
**export MAILJET_TEMPLATE_ID=** This is your mailjet template for sending temporary passwords to the user  

## Built With

* [Sinatra](https://github.com/sinatra/sinatra) - Used for the web development framework  
* [Ralyxa](https://github.com/sjmog/ralyxa) - Used to handle Alexa requests  
* [Sinatra ActiveRecord](https://github.com/sinatra-activerecord/sinatra-activerecord) - Used to handle SQLite database  
* [SQLite](https://www.sqlite.org/index.html) - Used for application database  


## Versioning

This application uses Semantic Versioning.

## Authors

* **Danny Buckley** - *Initial work* - [Me](https://github.com/DBuckley0126)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

