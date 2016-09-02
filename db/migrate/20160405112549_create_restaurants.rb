class CreateRestaurants < ActiveRecord::Migration
  def change
    create_table :restaurants do |t|
      t.string :name
      t.datetime :opening_time
      t.datetime :closing_time
      t.string :location

      t.timestamps null: false
    end
  end
end
