class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.integer :user_id
      t.integer :referred_id

      t.timestamps null: false
    end
  end
end
