class AddLatLongToCheckin < ActiveRecord::Migration
  def change
  	add_column :checkins , :lat , :float
  	add_column :checkins , :long , :float
  end
end
