class RemoveMenuFoodItemLinking < ActiveRecord::Migration
  def change
  	remove_column :food_items , :menu_id
  	add_column :food_items , :section_id , :integer
  end
end
