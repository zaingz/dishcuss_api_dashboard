class Qrcode < ActiveRecord::Base
	belongs_to :restaurant
	has_many :credit_histories

	has_one :offer_image

	#validates_uniqueness_of :code

	after_create :generate_token_code

	def generate_token_code
	    begin
	      self.code = SecureRandom.hex.to_s
	    end while self.class.exists?(code: code)
	    qr = RQRCode::QRCode.new(self.code)
		png = qr.as_png(
          resize_gte_to: false,
          resize_exactly_to: false,
          fill: 'white',
          color: 'black',
          size: 250,
          border_modules: 4,
          module_px_size: 6,
          file: nil # path to write
          )
		nam = "./public/QR code/" + self.code + ".png"
		IO.write(nam, png.to_s , {mode: 'wb'})
		self.img = nam
		self.save
	end
end
