class AddIndexToRestaurantName < ActiveRecord::Migration
  def change
  	add_index :restaurants, :name
  end
end
