class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.string :name
      t.text :summary
      t.references :restaurant

      t.timestamps null: false
    end
  end
end
