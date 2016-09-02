class AlterMessage < ActiveRecord::Migration
  def change
  	remove_column :messages , :user_id
  	remove_column :messages , :restaurant_id
  	add_column :messages , :sender_id , :integer
  	add_column :messages , :sender_type , :string
  	add_column :messages , :reciever_id , :integer
  	add_column :messages , :reciever_type , :string
  end
end
