class Referral < ActiveRecord::Base
	belongs_to :user
	belongs_to :referred, :class_name => 'User'
end
