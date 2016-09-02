class CreateCheckins < ActiveRecord::Migration
  def change
    create_table :checkins do |t|
      t.string :address
      t.references :post
      
      t.timestamps null: false
    end
  end
end
