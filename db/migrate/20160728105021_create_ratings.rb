class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :rate , default: 0
      t.integer :restaurant_id

      t.timestamps null: false
    end
  end
end
