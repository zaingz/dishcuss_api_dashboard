class Review < ActiveRecord::Base
	belongs_to :reviewable , :polymorphic => true
	belongs_to :reviewer, :class_name => 'User'

	acts_as_likeable
	acts_as_commentable

	has_many :reports , :as => 'reportable' ,dependent: :destroy
	has_many :dislikes, :as => 'dislikable' ,dependent: :destroy
end
