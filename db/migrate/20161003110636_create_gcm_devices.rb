class CreateGcmDevices < ActiveRecord::Migration
  def change
    create_table :gcm_devices do |t|
      t.string :token , default: ""
      t.string :device , default: ""
      t.integer :user_id
      t.timestamps null: false
    end
  end
end
