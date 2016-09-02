class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name , default: ""
      t.string :last_name , default: ""
      t.string :email , default: ""
      t.string :image , default: ""
      t.string :location , default: ""
      t.integer :gender

      t.timestamps null: false
    end
  end
end
