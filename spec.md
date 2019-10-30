# Specifications for the Sinatra Assessment

Specs:
- [x] Use Sinatra to build the app
  Sinatra::Base was used on the Application Controller
- [x] Use ActiveRecord for storing information in a database
  ActiveRecord is being used to perform any CRUD action
- [x] Include more than one model class (e.g. User, Post, Category)
  There is a Remember model and a User model
- [x] Include at least one has_many relationship on your User model (e.g. User has_many Posts)
  User has_many Remembers
- [x] Include at least one belongs_to relationship on another model (e.g. Post belongs_to User)
  A Remember belongs_to User
- [x] Include user accounts with unique login attribute (username or email)
  User accounts have unique username login
- [x] Ensure that the belongs_to resource has routes for Creating, Reading, Updating and Destroying
  The Remember model has the ability to preform .new, .create, .patch, .destory
- [x] Ensure that users can't modify content created by other users
  All routes check which user is logged in before preforming any action
- [x] Include user input validations
  Signup process checks email is valid though Regex, checks if email and username is unique
- [x] BONUS - not required - Display validation failures to user with error message (example form URL e.g. /posts/new)
  All routes now include alerts/error messages for all actions
- [ ] Your README.md includes a short description, install instructions, a contributors guide and a link to the license for your code
  README has been filled out

Confirm
- [x] You have a large number of small Git commits
- [x] Your commit messages are meaningful
- [x] You made the changes in a commit that relate to the commit message
- [x] You don't include changes in a commit that aren't related to the commit message