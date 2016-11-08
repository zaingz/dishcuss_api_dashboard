class RatingController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def create
		if params[:rating][:restaurant_id].present? && params[:rating][:rate].present?
			if Rating.where(restaurant_id: params[:rating][:restaurant_id]).where(user_id: @current_user.id).count > 0
				render json: {'message' => 'Already rated!'} , status: :ok
			else
				rat = Rating.create(rating_params)
				rat.update(user_id: @current_user.id)
				render json: {'message' => 'Successfully rated!'} , status: :ok
			end
		else
			render json: {'message' => 'Params missing'} , status: :unprocessable_entity
		end
	end

	private
	def rating_params
		params.require(:rating).permit(:rate, :restaurant_id)
	end
end
