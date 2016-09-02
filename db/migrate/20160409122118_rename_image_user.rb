class RenameImageUser < ActiveRecord::Migration
  def change
  	rename_column :users , :image , :avatar
  end
end
