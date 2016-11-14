class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.boolean :force , default: false
      t.string :version , default: ''
      t.timestamps null: false
    end
  end
end
