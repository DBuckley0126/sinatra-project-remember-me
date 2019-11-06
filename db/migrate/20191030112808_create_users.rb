class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.text :access_token
      t.string :first_name
      t.string :last_name
      t.text :temp_password
      t.boolean :verified
      t.text :vector
    end
  end
end
