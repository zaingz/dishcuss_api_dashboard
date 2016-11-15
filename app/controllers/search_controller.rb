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
			tot_review = Hash.new
		    tot_review["res"] =  [] 
		    tot_review["usr"] = []
			use = User.where(role: 0).where("name ~* ?", params[:name]).limit(5)
			res = Restaurant.approved.where("name ~* ?", params[:name]).limit(5)

			use.each do |us|
				 tot_review["usr"] << UserSocialSerializer.new(us)
			end

			res.each do |re|
				tot_review["res"] << RestaurantSocialSerializer.new(re)
			end
			
			render json: {restaurant: tot_review["res"] , user: tot_review["usr"] }  , status: :ok
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
		render json: { search: us } , status: :ok
	end

	def sec_search
		if params[:name].present?
			p "Searching Sections"
			arr = []
			cat = Restaurant.where('typee ~* ?' , params[:name]).uniq
			cat.each do |res|
				tempi = res
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
