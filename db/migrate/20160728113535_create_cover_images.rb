class CreateCoverImages < ActiveRecord::Migration
  def change
    create_table :cover_images do |t|
      t.string :image
      t.integer :restaurant_id
      t.timestamps null: false
    end
  end
end
