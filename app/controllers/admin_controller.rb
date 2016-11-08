class AdminController < ApplicationController
	before_filter :authenticate_user!
	before_filter :is_admin
	layout "admin"

	def index
		@restaurant = Restaurant.all
	end

	def rest_pending
		@restaurant = Restaurant.where(approved: false)
	end

	def rest_approved
		@restaurant = Restaurant.approved
	end

	def rest_featured
		@restaurant = Restaurant.featured
	end

	def end_users
		@user = User.where(role: 0)
	end

	def end_user_block
		user = User.find(params[:id])
		user.update(block: true)
		redirect_to :back
	end

	def end_user_unblock
		user = User.find(params[:id])
		user.update(block: false )
		redirect_to :back
	end

	def restaurant_users
		@user = User.where(role: 1)
	end

	def pundit
		@user = User.where(role: 3)
	end

	def edit_pundit
		p params
		@user = User.find(params[:id])
	end

	def update_pundit
		p params
		@user = User.find(params[:id])
		@user.update(pundit_update_params)
		if params[:user][:password].present?
			@user.update(password: params[:user][:password])
		end
		redirect_to admin_pundit_path
	end

	def delete_pundit
		user = User.find(params[:id])
		user.destroy
		redirect_to :back
	end

	def alL_reviews
		@review = Review.all
	end

	def user_checkins
		@checkin = Checkin.all
	end

	def user_posts
		@post = Post.all
	end

	def credit_history
		@history = CreditHistory.all
	end

	def notification
		@notification = Notification.find(params[:id])
		@notification.update(seen: true)
	end

	def unfeature_restaurant
		restaurant = Restaurant.approved.find(params[:id])
		restaurant.featured = false
		if restaurant.save
			redirect_to :back
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end


	def feature_restaurant
		restaurant = Restaurant.approved.find(params[:id])
		restaurant.featured = true
		if restaurant.save
			redirect_to :back
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end
	
	def approve_restaurant
		restaurant = Restaurant.find(params[:id])
		restaurant.approved = true
		if restaurant.save
			redirect_to :back
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end

	def unapprove_restaurant
		restaurant = Restaurant.find(params[:id])
		restaurant.approved = false
		if restaurant.save
			redirect_to :back
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end

	def create_pundit
		if user = User.find_by_email(params[:email])
			redirect_to :back
		else
			if params[:password].present?
				user = User.create(email: params[:email], password: params[:password] , name: params[:name] , username: params[:username] , role: 3)
				redirect_to :back
			else
				redirect_to :back
			end
		end
	end

	def create_credit_adjust
		if cred = CreditAdjustment.find_by_typee(params[:credit][:typee])
			cred.update(points: params[:credit][:points])
			render json: {'message' => 'Successfully Updated!'} , status: :ok
		else
			cred = CreditAdjustment.create credit_adjust_params
			render json: {'message' => 'Successfully created!'} , status: :created
		end
	end

	def enable_claim_restaurant
		if res = Restaurant.approved.find(params[:id])
			if res.claim_credit == false
				res.update(claim_credit: true)
				redirect_to :back
			else
				redirect_to :back , notice: 'Unprocessable Entity'
			end
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end

	def disapprove_claim_restaurant
		if res = Restaurant.approved.find(params[:id])
			if res.claim_credit == true
				res.update(claim_credit: false)
				redirect_to :back
			else
				redirect_to :back , notice: 'Unprocessable Entity'
			end
		else
			redirect_to :back , notice: 'Unprocessable Entity'
		end
	end

	def restaurant_detail
		@restaurant = Restaurant.find(params[:id])
	end

	def give_user_credit

	end

	def credits_sent
		if params[:email].present? && params[:credit].present?
			if u = User.find_by_email(params[:email])
				c = u.credit
				c.points = c.points + params[:credit].to_i
				c.save
			end
		end
		redirect_to :back
	end

	private
	def pundit_params
		params.require(:user).permit(:email, :password , :name , :username)
	end

	def pundit_update_params
		params.require(:user).permit(:email , :name , :username)
	end

	def credit_adjust_params
		params.require(:credit).permit(:typee , :points)
	end
end
