class AddRestIdsToNewsfeed < ActiveRecord::Migration
  def change
  	add_column :newsfeeds, :rest_ids, :integer, array: true, default: []
  end
end
