class AddTotCreditsAndConsumdInOffers < ActiveRecord::Migration
  def change
  	add_column :qrcodes , :consumed_credit , :integer , default: 0
  	add_column :qrcodes , :max_credit , :integer , default: 0
  end
end
