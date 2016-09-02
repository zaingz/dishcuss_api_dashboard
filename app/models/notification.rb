class Notification < ActiveRecord::Base
	belongs_to :target, :polymorphic => true
	belongs_to :notifier, :class_name => 'User'
end
