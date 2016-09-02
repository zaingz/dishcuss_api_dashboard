class AddSocializationGemColumnToRestaurant < ActiveRecord::Migration
  def change
  	add_column :restaurants, :followers_count, :integer , :default => 0
  	add_column :restaurants, :likers_count, :integer , :default => 0
  end
end
