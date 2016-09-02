class CoverImage < ActiveRecord::Base
	mount_uploader :image, ImageUploader
	belongs_to :restaurant
end
