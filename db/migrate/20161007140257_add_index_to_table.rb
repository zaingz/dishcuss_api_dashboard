class AddIndexToTable < ActiveRecord::Migration
  def change
  	add_index :reviews, :reviewer_id
  	add_index :posts, :user_id
  	add_index :restaurants, :approved
  end
end
