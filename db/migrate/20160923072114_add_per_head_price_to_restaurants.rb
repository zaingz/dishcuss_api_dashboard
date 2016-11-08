class AddPerHeadPriceToRestaurants < ActiveRecord::Migration
  def change
  	add_column :restaurants , :per_head , :integer , default: 0
  end
end
