class CreateQrcodes < ActiveRecord::Migration
  def change
    create_table :qrcodes do |t|
   	  t.string :code
   	  t.integer :restaurant_id
   	  t.integer :points
   	  t.string :description , default: ""
   	  t.string :img
      t.timestamps null: false
    end
  end
end
