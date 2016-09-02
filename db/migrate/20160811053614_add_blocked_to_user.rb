class AddBlockedToUser < ActiveRecord::Migration
  def change
  	add_column :users , :block , :boolean , default: false
  end
end
