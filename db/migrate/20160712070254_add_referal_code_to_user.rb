class AddReferalCodeToUser < ActiveRecord::Migration
  def change
  	add_column :users , :referal_code , :string , default: ""
  	
  end
end
