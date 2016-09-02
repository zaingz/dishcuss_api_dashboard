class AddColumnToMenus < ActiveRecord::Migration
  def change
  	add_column :restaurants , :approved , :boolean , default: false
  end
end
