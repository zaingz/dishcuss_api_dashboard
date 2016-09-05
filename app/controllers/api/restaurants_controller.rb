class RestaurantsController < ApplicationController
	before_filter :restrict_access , except:[:social , :featuredr , :search , :explore_rest , :nearby]
	before_filter :is_restaurant_owner , only:[:create , :destroy , :update , :qrcode]

	def create
		if params[:restaurant][:cover_image].present?
			restaurant = Restaurant.new restaurant_params
			restaurant.owner_id = @owner.id
			if restaurant.save
				if params[:restaurant][:image].present?
					params[:restaurant][:image].each do |a|
		            	@photo = Photo.create(:image => a, :imageable_id => restaurant.id , :imageable_type => 'Restaurant')
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
	            		@photo = Photo.create(:image => a, :imageable_id => restaurant.id , :imageable_type => 'Restaurant')
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
		restaurant = Restaurant.approved.find(params[:id])
		render json: restaurant , serializer: RestaurantSocialSerializer , root: 'restaurant, status: :ok
	end

	#def likeable
	#	restaurant = Restaurant.approved.find(params[:id])
	#	user = restaurant.likers(User)
	#	render json: user , serializer: Serializer, status: :ok
	#end

	def follow
		if follows = Restaurant.approved.find(params[:id])
			if @current_user.follows?(follows)
				render json: {'message' => 'Already followed!'} , status: :unprocessable_entity
			else
				@current_user.follow!(follows)
				type = 'Restaurant'
				n = NotificationHelper.followed_notification(@current_user.id , follows.id , type)
				render json: {'message' => 'Successfully followed!'} , status: :ok
			end
		end
	end

	def unfollow
		follows = Restaurant.approved.find(params[:id])
		if @current_user.follows?(follows)
			@current_user.unfollow!(follows)
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
			if res = Qrcode.find_by_code(params[:code])
				cre = @current_user.credit
				if cre.points >= res.points
					poi = cre.points - res.points
					cre.update(points: poi)
					cr_hist = CreditHistory.create(user_id: @current_user.id , qrcode_id: res.id , restaurant_id: res.restaurant_id , price: res.points)
					NotificationHelper.credit_history_notification(@current_user.id , res.restaurant_id)
					render json: {'message' => 'Successfully claimed!'} , status: :ok
				else
					render json: {'message' => 'Need more points to claim that item!'} , status: :ok
				end
			else
				render json: {'message' => 'Invalid Qrcode!'} , status: :unprocessable_entity
			end
		else
			render json: {'message' => 'QR code missing!'} , status: :unprocessable_entity
		end
	end

	def qrcode
		if res = Restaurant.where(owner_id: @current_user.id).approved.find(params[:restaurant][:restaurant_id])
			if params[:restaurant][:image].present?
				qr = Qrcode.create qrcode_params
				q_i = OfferImage.create(image: params[:restaurant][:image] , qrcode_id: qr.id)
				render json: qr , serializer: QrcodeSerializer , status: :ok
			else
				render json: {"message" => "Image missing"} , status: :unprocessable_entity
			end
		end
	end

	def search
		if params[:name].present?
			res = Restaurant.approved.where("name ~* ?", params[:name])
			render json: res , each_serializer: RestaurantSocialSerializer , status: :ok
		else
			render json: {'message' => 'Restaurant name missing !'} , status: :unprocessable_entity
		end
	end

	def explore_rest
		res = Restaurant.approved
		render json: res , each_serializer: RestaurantSocialSerializer , status: :ok
	end

	def nearby
		p params
		if params[:lat].present? && params[:long].present?
			res = Restaurant.near([params[:lat], params[:long]], 20, :units => :km)
			render json: res , each_serializer: RestaurantSocialSerializer , status: :ok
		else
			render json: {'message' => 'Latitude longitude missing'} , status: :unprocessable_entity
		end
	end

	private
	def restaurant_params
		params.require(:restaurant).permit(:name , :opening_time , :closing_time , :location , :image ,:photo_id )
	end

	def qrcode_params
		params.require(:restaurant).permit(:restaurant_id , :points , :description)
	end
end
