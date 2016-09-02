class CreateOfferImages < ActiveRecord::Migration
  def change
    create_table :offer_images do |t|
	  t.string :image 
      t.integer :qrcode_id
      t.timestamps null: false
    end
  end
end
