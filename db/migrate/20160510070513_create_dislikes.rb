class CreateDislikes < ActiveRecord::Migration
  def change
    create_table :dislikes do |t|

      t.integer  :dislikeable_id
      t.string  :dislikeable_type
      t.integer  :disliker_id
      t.timestamps null: false
    end
  end
end
