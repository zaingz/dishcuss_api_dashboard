class AddShareFunctionality < ActiveRecord::Migration
  def change
  	add_column :posts , :shares , :integer , default: 0
  	add_column :reviews , :shares , :integer , default: 0
  end
end
