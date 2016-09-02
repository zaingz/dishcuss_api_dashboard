class Newsfeed < ActiveRecord::Base
	belongs_to :feed, :polymorphic => true
end
