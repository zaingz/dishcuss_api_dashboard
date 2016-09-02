class RenameAndAddDob < ActiveRecord::Migration
  def change
  	rename_column :users , :first_name , :name
  	rename_column :users , :last_name , :username

  	add_column :users , :dob , :datetime
  end
end
