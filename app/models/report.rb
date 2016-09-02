class Report < ActiveRecord::Base
	belongs_to :reportable, :polymorphic => true
	belongs_to :user
end
