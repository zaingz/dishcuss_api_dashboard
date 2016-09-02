class RenamePictureToImage < ActiveRecord::Migration
  def change
  	rename_column :photos , :picture , :image
  end
end
