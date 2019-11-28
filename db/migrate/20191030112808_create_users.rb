class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.text :alexa_id
      t.string :first_name
      t.string :last_name
      t.text :temp_code
      t.boolean :email_verified
      t.boolean :alexa_linked
      t.text :vector
      t.text :unique_code
    end
  end
end
