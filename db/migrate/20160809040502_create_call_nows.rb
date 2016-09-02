class CreateCallNows < ActiveRecord::Migration
  def change
    create_table :call_nows do |t|

      t.string :number
      t.integer :restaurant_id
      t.timestamps null: false
    end
  end
end
