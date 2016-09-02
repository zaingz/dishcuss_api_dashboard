class Section < ActiveRecord::Base
	belongs_to :menu
	has_many :food_items , dependent: :destroy
end
