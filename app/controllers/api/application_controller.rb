class ApplicationController < ActionController::API
	#include Knock::Authenticable

	include ActionController::HttpAuthentication::Token::ControllerMethods
	include ActionController::Serialization

	require './app/controllers/concerns/notification.rb'
	require './app/controllers/concerns/credit.rb'

	private

	def restrict_access
		unless restrict_access_to_user
			render json:{'message' => 'Invalid Api tokken' },status: :unauthorized
			return 
		end
		@current_user = @identity.user if @identity
	end

	#request.headers["token"]

	def restrict_access_to_user
		authenticate_or_request_with_http_token do |token, options| 
			if  Identity.exists?(token: token)
				@identity = Identity.find_by_token token
			end
		end
	end

	def is_restaurant_owner
		if @current_user.role == 'restaurant_owner'
			@owner = @current_user
		else
			render json:{'message' => 'User is not restaurant owner' },status: :unauthorized
		end
	end

	def is_admin
		if @current_user.role == 'admin'
			@admin = @current_user
		else
			render json:{'message' => 'User is not admin' },status: :unauthorized
		end
	end

	def is_end_user
		if @current_user.role == 'end_user'
			@end_user = @current_user
		else
			render json:{'message' => 'User is not end user' },status: :unauthorized
		end
	end
end
