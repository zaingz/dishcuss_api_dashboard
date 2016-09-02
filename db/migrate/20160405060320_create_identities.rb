class CreateIdentities < ActiveRecord::Migration
  def change
    create_table :identities do |t|
      t.string :provider , default: ""
      t.string :uid , default: ""
      t.string :url , default: ""
      t.string :token , default: ""
      t.datetime :expires_at
      t.references :user

      t.timestamps null: false
    end
  end
end
