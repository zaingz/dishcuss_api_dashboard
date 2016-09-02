class Dislike < ActiveRecord::Base
	belongs_to :dislikeable, :polymorphic => true
	belongs_to :disliker, :class_name => 'User'
end
