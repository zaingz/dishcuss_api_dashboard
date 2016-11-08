class SearchController < ApplicationController
	before_filter :restrict_access, only: [:find_fb_friends]
	before_filter :is_end_user, only: [:find_fb_friends]

	def res_search
		if params[:name].present?
			res = Restaurant.approved.where("name ~* ?", params[:name]).limit(5)
			render json: res , each_serializer: RestaurantSocialSerializer , root: 'restaurant' , status: :ok
		else
			render json: {'message' => 'Restaurant name missing !'} , status: :unprocessable_entity
		end
	end

	def search
		if params[:name].present?
			use = User.where(role: 0).where("name ~* ?", params[:name]).limit(5)
			res = Restaurant.approved.where("name ~* ?", params[:name]).limit(5)
			#render json: res , each_serializer: RestaurantSocialSerializer , status: :ok
			render json: {restaurant: ActiveModel::ArraySerializer.new(res , each_serializer: RestaurantSocialSerializer , root: "restaurants"), user: ActiveModel::ArraySerializer.new(use, each_serializer: UserSocialSerializer , root: "users")}  , status: :ok
		else
			render json: {'message' => 'Restaurant/User name missing !'} , status: :unprocessable_entity
		end
	end

	def find_fb_friends
		p params[:user]
		p "Parsing"
		ar = JSON.parse(params[:user])
		us = []
		ar.each do |useri|
			user_a = Identity.where(provider: 'Facebook').where(uid: useri)
			if user_a.count > 0
				user = user_a.first.user
				if user.dp.present?
					k = user.dp.url
				else
					k = user.avatar
				end
				us.push({id: user.id , name: user.name , username: user.username , avatar: k , location: user.location , follows: @current_user.follows?(user) , followers: user.followers_count})
			end
		end
		render json: us , status: :ok
	end

	def sec_search
		if params[:name].present?
			p "Searching Sections"
			arr = []
			cat = Section.where('title ~* ?' , params[:name])
			cat.each do |sec|
				tempi = sec.menu.restaurant
				unless arr.include?(tempi)
					arr << tempi
				end
			end
			render json: arr , each_serializer: RestaurantSocialSerializer , root: "restaurant"  , status: :ok
		else
			render json: {'message' => 'Section name missing !'} , status: :unprocessable_entity
		end
	end
end
