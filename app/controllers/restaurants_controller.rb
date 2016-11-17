class RestaurantsController < ApplicationController
	before_filter :restrict_access , except:[:social , :featuredr  , :explore_rest , :nearby , :send_all]
	before_filter :is_restaurant_owner , only:[:create , :destroy , :update , :qrcode]

	def create
		if params[:restaurant][:cover_image].present?
			restaurant = Restaurant.new restaurant_params
			restaurant.owner_id = @owner.id
			if restaurant.save
				if params[:restaurant][:image].present?
					params[:restaurant][:image].each do |a|
		            	photo = Photo.create(:image => a, :imageable_id => restaurant.id , :imageable_type => 'Restaurant')
		          	end
		        end
		        c_image = CoverImage.create(:image => params[:restaurant][:cover_image] , :restaurant_id => restaurant.id)
				render json: restaurant, status: :created
			else
				render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
			end
		else
			render json: {'message' => 'Cover Image Missing'} , status: :unprocessable_entity
		end
	end

	def index
		res = Restaurant.approved
		render json: res, status: :ok
	end

	def destroy
		restaurant = Restaurant.approved.where(owner_id: @owner.id)
		if restaurant = restaurant.where(id: params[:id])
			res = Restaurant.approved.find(params[:id])
			head :no_content
		end
	end

	def update
		restaurant = Restaurant.approved.where(owner_id: @owner.id)
		if restaurant = restaurant.find(params[:id])
			restaurant.update_attributes(restaurant_params)
			if params[:restaurant][:image].present?
				if params[:restaurant][:photo_id].present? && params[:restaurant][:image].count==1
					p = restaurant.photos.find(params[:restaurant][:photo_id])
					p.update image: params[:restaurant][:image].first
				else
					params[:restaurant][:image].each do |a|
	            		photo = Photo.create(:image => a, :imageable_id => restaurant.id , :imageable_type => 'Restaurant')
	          		end
	          	end
			end
			if params[:restaurant][:cover_image].present?
				restaurant.cover_image.update(:image => params[:restaurant][:cover_image])
			end
			render json: {'message' => 'Restaurant successfully updated!'} , status: :ok
		end
	end

	def social
		restaurant = Restaurant.approved.find_by_id(params[:id])
		ue = nil
		has = request.headers.env.select{|k, _| k =~ /^HTTP_/}
		if has["HTTP_AUTHORIZATION"].present?
			a = has["HTTP_AUTHORIZATION"].split('Token token=')[1]
			iden = Identity.find_by_token(a)
			if iden
				ue = iden.user
			end
		end
		render json: restaurant , serializer: RestaurantSocialSerializer , option_name: ue , status: :ok
	end

	#def likeable
	#	restaurant = Restaurant.approved.find(params[:id])
	#	user = restaurant.likers(User)
	#	render json: user , serializer: Serializer, status: :ok
	#end

	def follow
		if follows = Restaurant.approved.find_by_id(params[:id])
			if @current_user.follows?(follows)
				render json: {'message' => 'Already followed!'} , status: :unprocessable_entity
			else
				@current_user.follow!(follows)
				if @current_user.newsfeed.present?
					@current_user.newsfeed.rest_ids.push(follows.id)
					@current_user.newsfeed.save
				else
					news = Newsfeed.create(feed_id: @current_user.id , feed_type: 'User' , rest_ids: [follows.id])
				end
				type = 'Restaurant'
				n = NotificationHelper.followed_notification(@current_user.id , follows.id , type)
				render json: {'message' => 'Successfully followed!'} , status: :ok
			end
		end
	end

	def unfollow
		follows = Restaurant.approved.find_by_id(params[:id])
		if @current_user.follows?(follows)
			@current_user.unfollow!(follows)
			@current_user.newsfeed.rest_ids.delete(params[:id].to_i)
			@current_user.newsfeed.save
			type = 'Restaurant'
			n = NotificationHelper.unfollowed_notification(@current_user.id , follows.id , type)
			render json: {'message' => 'Successfully unfollowed!'} , status: :ok
		else
			render json: {'message' => 'Follow restaurant first!'} , status: :bad_request
		end
	end

	def featuredr
		res = Restaurant.featured
		render json: res, status: :ok
	end

	def claim_credit
		if params[:code].present?
			if res = Qrcode.find_by_id(params[:offer_id])
				if res.code == params[:code]
					cre = @current_user.credit
					if res.max_credit < ( res.consumed_credit +  res.points )
						render json: {'message' => 'Offer is expired'} , status: :ok
					elsif cre.points >= res.points
						poi = cre.points - res.points
						cre.update(points: poi)
						cr_hist = CreditHistory.create(user_id: @current_user.id , qrcode_id: res.id , restaurant_id: res.restaurant_id , price: res.points)
						NotificationHelper.credit_history_notification(@current_user.id , res.restaurant_id)
						render json: {'message' => 'Successfully claimed!'} , status: :ok
					else
						render json: {'message' => 'Need more points to claim that item!'} , status: :ok
					end
				else
					render json: {'message' => 'Qrcode doesnot belongs to that restaurant!'} , status: :unprocessable_entity
				end
			else
				render json: {'message' => 'Invalid Qrcode!'} , status: :unprocessable_entity
			end
		else
			render json: {'message' => 'QR code missing!'} , status: :unprocessable_entity
		end
	end

	def qrcode
		if res = Restaurant.where(owner_id: @current_user.id).approved.find_by_id(params[:restaurant][:restaurant_id])
			if params[:restaurant][:image].present?
				qr = Qrcode.create qrcode_params
				q_i = OfferImage.create(image: params[:restaurant][:image] , qrcode_id: qr.id)
				render json: qr , serializer: QrcodeSerializer , status: :ok
			else
				render json: {"message" => "Image missing"} , status: :unprocessable_entity
			end
		end
	end

	def explore_rest
		#sql = "SELECT restaurants.id
		#		FROM restaurants
		#		LEFT JOIN ratings
		#		ON restaurants.id=ratings.restaurant_id 
		#		WHERE restaurants.approved=true;"
		#records_array = Restaurant.connection.execute(sql, :skip_logging)

		#restu = []
		#records_array.each do |sd|
		#	restu.push(sd.to_json)
		#end

		res = Restaurant.approved
		c = res.highest_rated
		
		#render json: { 'records' => restu } , status: :ok
		render json: c , each_serializer: RestaurantExploreSerializer , root: "restaurants" , status: :ok
	end

	def nearby
		p params
		if params[:lat].present? && params[:long].present?
			res = Restaurant.approved.near([params[:lat], params[:long]], 20, :units => :km)
			lati_longi = [params[:lat] , params[:long]]
			render json: res , each_serializer: RestaurantNearbySerializer , root: "restaurants" ,  scope: { option_name: lati_longi }, status: :ok
		else
			render json: {'message' => 'Latitude longitude missing'} , status: :unprocessable_entity
		end
	end

	def chk_follow_like
		user = @current_user
		if ch_res = Restaurant.approved.find_by_id(params[:id])
			chk = user.follows?(ch_res)
			chk_like = user.likes?(ch_res)
			render json: {'follows' => chk , 'likes' => chk_like} , status: :ok
		else
			render json: {'message' => 'Restaurant not found'} , status: :unprocessable_entity
		end
	end

	def unlike
		user = @current_user
		ch_res = Restaurant.approved.find_by_id(params[:id])
		if ch_res = Restaurant.approved.find_by_id(params[:id])
			if user.likes?(ch_res)
				user.unlike!(ch_res)
				render json: {'message' => 'Unlike Successfully'} , status: :ok
			else
				render json: {'message' => 'Like first '} , status: :ok
			end
		else
			render json: {'message' => 'Restaurant not found'} , status: :unprocessable_entity
		end
	end

	def send_all
		ch_res = Restaurant.approved
		render json: ch_res , each_serializer: RestaurantAllSerializer , status: :ok
	end

	private
	def restaurant_params
		params.require(:restaurant).permit(:name , :opening_time , :closing_time , :location , :image ,:photo_id )
	end

	def qrcode_params
		params.require(:restaurant).permit(:restaurant_id , :points , :description)
	end
end
