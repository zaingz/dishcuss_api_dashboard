class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :image_id
      t.string :image_type
      t.string :picture

      t.timestamps null: false
    end
  end
end
