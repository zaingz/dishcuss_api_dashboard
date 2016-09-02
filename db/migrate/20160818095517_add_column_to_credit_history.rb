class AddColumnToCreditHistory < ActiveRecord::Migration
  def change
  	add_column :credit_histories , :qrcode_id , :integer
  end
end
