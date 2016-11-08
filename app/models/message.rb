class Message < ActiveRecord::Base
	enum status: [:pending , :cleared]
	#belongs_to :user
	#belongs_to :restaurant
end
