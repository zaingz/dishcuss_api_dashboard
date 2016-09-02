class AddPolymorphicToReport < ActiveRecord::Migration
  def change
  	add_column :reports , :reportable_id , :integer
  	add_column :reports , :reportable_type , :string
  end
end
