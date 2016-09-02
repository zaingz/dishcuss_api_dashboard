require 'active_support/concern'
module CreditHelper
	extend ActiveSupport::Concern

	def self.review_credit(user)
		cred = User.find(user).credit
		if c_adj = CreditAdjustment.find_by_typee('Review')
			poin = cred.points + c_adj.points
			cred.update(points: poin)
		end
	end

	def self.checkin_credit(user , address)
		p user
		user = User.find(user)
		chk = 0
		user.posts.each do |post|
			if post.checkin.present?
				if post.checkin.address ==  address 
					chk = chk + 1
				end
			end
		end

		if chk == 1
			cred = user.credit
			if c_adj = CreditAdjustment.find_by_typee('Checkin')
				poin = cred.points + c_adj.points
				cred.update(points: poin)
				return true
			else
				return false
			end
		else
			return false
		end
	end
end
