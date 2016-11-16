class FoodItem < ActiveRecord::Base
	belongs_to :section
	has_and_belongs_to_many :categories

	attr_accessor :category_id , :category , :restaurant_id
	attr_accessor :image , :photo_id

	acts_as_likeable
	has_many :photos , :as => 'imageable'
	accepts_nested_attributes_for :photos

	has_many :dislikes, :as => 'dislikable'

end
