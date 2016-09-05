class AddPassToken < ActiveRecord::Migration
  def change
  	add_column :users , :reset_password_token , :string
  	add_column :users , :reset_password_sent_at , :string
  end
end
