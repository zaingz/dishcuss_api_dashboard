class Photo < ActiveRecord::Base
	mount_uploader :image, ImageUploader
	belongs_to :imageable, :polymorphic => true
	validates_associated :imageable
	
	has_many :reports , :as => 'reportable' 
end
