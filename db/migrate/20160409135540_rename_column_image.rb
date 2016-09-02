class RenameColumnImage < ActiveRecord::Migration
  def change
  	rename_column :photos , :image_id , :imageable_id
  	rename_column :photos , :image_type , :imageable_type
  end
end
