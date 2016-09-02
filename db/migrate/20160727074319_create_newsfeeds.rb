class CreateNewsfeeds < ActiveRecord::Migration
  def change
    create_table :newsfeeds do |t|
      t.integer :user_id
      t.integer :ids , array: true, default: []

      t.timestamps null: false
    end
  end
end
