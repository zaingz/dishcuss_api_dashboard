class AddPolymorphicAndRemove < ActiveRecord::Migration
  def change
  	remove_column :newsfeeds , :user_id
  	add_column :newsfeeds , :feed_id , :integer
  	add_column :newsfeeds , :feed_type , :string
  end
end
