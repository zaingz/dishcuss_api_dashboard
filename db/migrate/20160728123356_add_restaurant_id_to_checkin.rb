class AddRestaurantIdToCheckin < ActiveRecord::Migration
  def change
  	add_column :checkins , :restaurant_id , :integer
  end
end
