class AddFeatureToRestaurant < ActiveRecord::Migration
  def change
  	add_column :restaurants , :featured , :boolean , default: false
  end
end
