class AdminController < ApplicationController
	before_filter :restrict_access
	before_filter :is_admin

	def feature_restaurant
		restaurant = Restaurant.approved.find(params[:id])
		restaurant.featured = true
		if restaurant.save
			render json: {'message' => 'Restaurant successfully featured!'} , status: :ok
		else
			render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
		end
	end
	
	def approve_restaurant
		restaurant = Restaurant.find(params[:id])
		restaurant.approved = true
		if restaurant.save
			render json: {'message' => 'Restaurant successfully approved!'} , status: :ok
		else
			render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
		end
	end

	def create_pundit
		if user = User.find_by_email(params[:user][:email])
			render json: {'message' => 'Already signedup!'} , status: :ok
		else
			if params[:user][:password].present?
				user = User.create pundit_params
				render json: {'message' => 'Successfully created!'} , status: :created
			else
				render json: {'message' => 'Missing params!'} , status: :unprocessable_entity
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
		if res = Restaurant.find(params[:id])
			if res.claim_credit == false
				res.update(claim_credit: true)
				render json: {'message' => 'Successfully Enabled!'} , status: :ok
			else
				render json: {'message' => 'Already Enabled!'} , status: :ok
			end
		else
			render json: {'message' => 'Restaurant not found!'} , status: :not_found
		end
	end

	private
	def pundit_params
		params.require(:user).permit(:email, :password)
	end

	def credit_adjust_params
		params.require(:credit).permit(:typee , :points)
	end
end
