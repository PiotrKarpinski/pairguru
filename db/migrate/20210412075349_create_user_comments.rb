class CreateUserComments < ActiveRecord::Migration[5.2]
  def change
    create_table :user_comments do |t|
      t.text :content
      t.references :movie, index: true
      t.references :user, index: true
      t.timestamps
    end
  end
end
