class AddLikeableToPostAndReview < ActiveRecord::Migration
  def change
  	add_column :posts, :likers_count, :integer, :default => 0
  	add_column :reviews, :likers_count, :integer, :default => 0
  end
end
