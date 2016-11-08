class ReferalCodeUsed < ActiveRecord::Migration
  def change
  	add_column :users , :referal_code_used , :boolean , default: false
  end
end
