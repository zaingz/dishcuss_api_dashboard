class CreateCreditAdjustments < ActiveRecord::Migration
  def change
    create_table :credit_adjustments do |t|
      t.string :typee , default: ""
      t.integer :points , default: 0

      t.timestamps null: false
    end
  end
end
