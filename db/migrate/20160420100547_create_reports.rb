class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.text  :reason
      t.integer  :user_id


      t.timestamps null: false
    end
  end
end
