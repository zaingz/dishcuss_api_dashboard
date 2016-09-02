class AddQrcodeToRestaurant < ActiveRecord::Migration
  def change
  	add_column :restaurants , :qrcode , :string
  end
end
