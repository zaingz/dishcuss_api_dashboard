class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :title
      t.text :summary
      t.integer :rating ,:max => 5 , :min => 1
      t.integer :reviewable_id
      t.string :reviewable_type

      t.timestamps null: false
    end
  end
end
