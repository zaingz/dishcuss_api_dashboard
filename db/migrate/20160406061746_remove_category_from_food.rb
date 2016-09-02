class RemoveCategoryFromFood < ActiveRecord::Migration
  def change
  	remove_column :food_items , :category
  end
end
