class CreateFoodItems < ActiveRecord::Migration
  def change
    create_table :food_items do |t|
      t.string :name
      t.string :category
      t.float :price
      t.references :menu

      t.timestamps null: false
    end
  end
end
