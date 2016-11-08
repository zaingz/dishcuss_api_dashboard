class ReferralController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def create
		if user = User.find_by_referal_code(params[:referral_code])
			if user.id == @current_user.id
				render json: {'message' => 'Cannot use your own referal code'} , status: :bad_request
			elsif @current_user.referal_code_used == true
				render json: {'message' => 'Referal Code already used'} , status: :unprocessable_entity
			else
				#credit adjust exist
				#pick credit points
				#credit add
				if c_adj = CreditAdjustment.find_by_typee('Referal') 
					chk = false
					if ref = Referral.find_by_referred_id(@current_user.id)
						if ref.user_id == user.id
							render json: {'message' => 'Referal code already used'} , status: :unprocessable_entity
						else
							chk = true
						end
					else
							chk = true			
					end

					if chk == true
						cre = @current_user.credit
						poin = cre.points + c_adj.points
						cre_c = user.credit
						poin_c = cre_c.points + c_adj.points
						@current_user.update(referal_code_used: true)
						re = Referral.create(user_id: user.id , referred_id: @current_user.id)
						cre.update(points: poin)
						NotificationHelper.credit_notification(@current_user.id , "promo code")
						cre_c.update(points: poin_c)
						NotificationHelper.credit_notification(user.id , 'promo code')
						render json: {'message' => 'Points added'} , status: :ok
					end
				else
					render json: {'message' => 'Service not available'} , status: :unprocessable_entity
				end
			end
		else
			render json: {'message' => 'Invalid referral code'} , status: :bad_request
		end
	end

	def get_users
		h = Array.new
		@current_user.referrals.each do |referal|
			user = referal.referred
			h.push({'id' => user.id , 'name' => user.name , 'username' => user.username , 'email' => user.email})
		end
		p h
		render json: h , root: 'referral' , status: :ok
	end
end
