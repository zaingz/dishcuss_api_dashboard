class WebController < ApplicationController

	def landing

	end

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
		if @restaurant.menu.present?
			@menu = @restaurant.menu.sections
		else
			@menu = []
		end
		@reviews = @restaurant.reviews.order(created_at: 'DESC')
		@photos = @restaurant.photos.order(created_at: 'DESC')
		@checkins = @restaurant.checkins.order(created_at: 'DESC').limit(10)
	end

	def user_profile
		@user = User.find(params[:id])
		@reviews = Review.where(reviewer_id: @user.id).order(created_at: 'DESC')
		@photos = []
		@user.posts.order(created_at: 'DESC').each do |post|
			post.photos.each do |photo|
				@photos.push({'photo' => photo.image_url })
			end
		end
		@followings = @user.followees(User)
		@followers = @user.followers(User)
	end

end
