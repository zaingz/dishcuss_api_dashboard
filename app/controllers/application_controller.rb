class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session

  include ActionController::HttpAuthentication::Token::ControllerMethods
  include ActionController::Serialization

  include Devise::Controllers::Helpers

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


	def restrict_access_to_user
		authenticate_or_request_with_http_token do |token, options| 
			if  Identity.exists?(token: token)
				@identity = Identity.find_by_token token
			end
		end
	end

	def is_restaurant_owner
		if user_signed_in?
			if @current_user.role == 'restaurant_owner'
				@owner = @current_user
			elsif @current_user.role == 'admin'
				@owner = @current_user
			else
				redirect_to '/' , status: :unauthorized
			end
		else
			redirect_to '/' , status: :unauthorized
		end
	end

	def is_admin
		if user_signed_in?
			if @current_user.role == 'admin'
				@admin = @current_user
			else
				redirect_to '/' , status: :unauthorized
			end
		else
			redirect_to '/' , status: :unauthorized
		end
	end

	def is_end_user
		if @current_user.role == 'end_user'
			@end_user = @current_user
		else
			redirect_to '/' ,status: :unauthorized
		end
	end
end
