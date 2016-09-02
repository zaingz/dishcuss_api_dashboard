class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :notifier_id
      t.string :notifier_type

      t.integer :target_id
      t.string :target_type

      t.text :body
      t.boolean :seen , default: false

      t.timestamps null: false
    end
  end
end
