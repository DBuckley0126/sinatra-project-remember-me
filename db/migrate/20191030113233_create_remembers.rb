class CreateRemembers < ActiveRecord::Migration
  def change
    create_table :remembers do |t|
      t.string :phrase
      t.string :answer
      t.integer :user_id

      t.timestamps
    end
  end
end
