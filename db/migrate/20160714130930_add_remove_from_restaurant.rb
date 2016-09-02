class AddRemoveFromRestaurant < ActiveRecord::Migration
  def change
  	remove_column :restaurants , :qrcode
  	add_column :restaurants , :claim_credit , :boolean , default: false
  end
end
