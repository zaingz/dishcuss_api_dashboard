class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :body
      t.integer :status , default: 0
      t.integer :restaurant_id
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
