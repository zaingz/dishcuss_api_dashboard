class WebController < ApplicationController

	def signin

	end

	def signup

	end

	def signup_detail

	end

	def select_restaurant

	end

	def restaurant_detail
		@restaurant = Restaurant.approved.find(params[:id])
		rati = 0
		@restaurant.ratings.each do |rat|
			rati = rati + rat.rate
		end
		@coun = @restaurant.ratings.count
		if @coun != 0
			@rating = rati/@restaurant.ratings.count
		else
			@rating = 0
		end
		@call_now = @restaurant.call_nows.first
		@menu = @restaurant.menu.sections
	end

	def user_profile

	end
end
