class AddSocializationGemColumnToFoodItems < ActiveRecord::Migration
  def change
  	add_column :food_items, :likers_count, :integer , :default => 0
  end
end
