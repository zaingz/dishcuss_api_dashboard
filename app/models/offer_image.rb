class OfferImage < ActiveRecord::Base
	mount_uploader :image, ImageUploader
	belongs_to :qrcode
end
