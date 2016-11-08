class CheckinsController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user
	def update

		if post= Post.find_by_id(params[:id])
			if post.user == @current_user
				if post.checkin.update(checkin_params)
					render json: {'message' => 'Susssessfully Updated!'} , status: :ok
				else
					render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
				end
			else
				render json: {'message' => 'Unauthorized!'} , status: :unauthorized
			end
		end
	end

	private
	def checkin_params
		params.require(:checkin).permit(:address ,:lat , :long)
	end
end
