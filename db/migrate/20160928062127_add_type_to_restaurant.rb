class AddTypeToRestaurant < ActiveRecord::Migration
  def change
  	add_column :restaurants , :typee , :string , default: 'Restaurant'
  end
end
