class Restaurant < ActiveRecord::Base

	geocoded_by :location
	after_validation :geocode

	has_one :menu , dependent: :destroy
	belongs_to :owner , :class_name => 'User'
	has_many :reviews , :as => 'reviewable' ,dependent: :destroy

	acts_as_followable
	acts_as_likeable

	has_many :photos , :as => 'imageable' ,dependent: :destroy
	accepts_nested_attributes_for :photos

	#has_many :messages , dependent: :destroy

	has_many :notifications , :as => 'target' ,dependent: :destroy

	has_many :dislikes, :as => 'dislikable' ,dependent: :destroy

	has_many :credit_histories , dependent: :destroy

	has_many :qrcodes , dependent: :destroy

	has_one :newsfeed , :as => 'feed' ,dependent: :destroy

	has_many :ratings ,  dependent: :destroy
	has_one :cover_image , dependent: :destroy
	has_many :checkins ,dependent: :destroy

	has_many :call_nows ,dependent: :destroy

	attr_accessor :image
	attr_accessor :photo_id

	scope :approved, lambda {where(:approved => true)}
	scope :featured, lambda {where(:featured => true)}

	scope :highest_rated, lambda {where("restaurants.id in (select restaurant_id from restaurants)").group('restaurants.id').joins(:ratings).order('AVG(ratings.rate) DESC')}

end
