class Menu < ActiveRecord::Base
	belongs_to :restaurant
	has_many :sections, dependent: :destroy

	#accepts_nested_attributes_for :food_items
end
