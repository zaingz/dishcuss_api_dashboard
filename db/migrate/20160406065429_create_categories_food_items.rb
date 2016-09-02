class CreateCategoriesFoodItems < ActiveRecord::Migration
  def change
    create_table :categories_food_items, id: false do |t|
      t.integer :category_id
      t.integer :food_item_id
    end
    add_index :categories_food_items , ["category_id","food_item_id"]
  end
end
