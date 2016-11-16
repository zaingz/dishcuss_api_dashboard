class Post < ActiveRecord::Base
	has_one :checkin , dependent: :destroy
	accepts_nested_attributes_for :checkin
	belongs_to :user
	
	acts_as_likeable
	acts_as_commentable
	
	has_many :photos , :as => 'imageable' ,dependent: :destroy
	accepts_nested_attributes_for :photos

	has_many :dislikes, :as => 'dislikable'
	attr_accessor :image , :photo_id

end
