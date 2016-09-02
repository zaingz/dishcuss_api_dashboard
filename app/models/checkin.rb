class Checkin < ActiveRecord::Base
	belongs_to :post
	belongs_to :restaurant

	#after_create :credit_points

	#def credit_points
	#	@current_user.posts.each do |post|
	#		if post.checkin.present?
	#			if post.checkin.address ==  ''
	#				cred = @current_user.credit
	#				if c_adj = CreditAdjustment.find_by_typee('Checkin')
	#					poin = cred.points + c_adj.points
	#					cred.update(points: poin)
	#				end
	#			end
	#		end
	#	end
	#end
end
