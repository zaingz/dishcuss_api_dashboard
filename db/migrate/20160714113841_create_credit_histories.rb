class CreateCreditHistories < ActiveRecord::Migration
  def change
    create_table :credit_histories do |t|
      t.integer :user_id
      t.integer :restaurant_id
      t.integer :price

      t.timestamps null: false
    end
  end
end
