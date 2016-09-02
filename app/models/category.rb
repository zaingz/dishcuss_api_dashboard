class Category < ActiveRecord::Base
	has_and_belongs_to_many :food_items
	validates_uniqueness_of :name
end
