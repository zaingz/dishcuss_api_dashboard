class UsersController < ApplicationController
	#before_action :authenticate , :except => [:create]
	before_filter :restrict_access, except: [:create , :signin ,:restaurant_user_create , :verify_email , :social ]
	before_filter :is_end_user, except: [:create , :signin , :social ,:restaurant_user_create , :signout , :verify_email , :notifications , :notification_seen , :update] 

	def create
		if user = User.find_by_email(params[:user][:email])
			render json: {'message' => 'Already signedup!'} , status: :ok
		else
			p params
			if params[:user][:password].blank?
				ident = params[:user][:identities_attributes]['0']
				p ident
				if ident[:provider].present? && ident[:uid].present? && ident[:token].present? 
					if user = User.create(user_params)
						user.update(verified: true)
						user.generate_referral_code
						user.save
						cred = Credit.create(user_id: user.id)
						if params[:user][:referal_code].present?
							if u = User.find_by_referal_code(params[:user][:referal_code])
								user.referal_notification
								u.referal_sender_notification
							end
						end
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				else
					render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
				end
			elsif(params[:user][:password].length >= 8 && params[:user][:password].length <= 16)
				pass = BCrypt::Password.create(params[:user][:password])
				user = User.create( email: params[:user][:email] , :encrypted_password => pass )
				user.update(user_create_params)
				user.generate_referral_code
				user.generate_email_verification_code
				user.save
				cred = Credit.create(user_id: user.id)
				identity = Identity.new(:provider => 'Dishcuss' , :user_id => user.id)
				identity.generate_token
			    identity.save
			    if params[:user][:referal_code].present?
					if u = User.find_by_referal_code(params[:user][:referal_code])
						user.referal_notification
						u.referal_sender_notification
					end
				end
				render json: identity , serializer: UserTokenSerializer, status: :created
				#UserMailer.welcome_email(user).deliver_later
			else
				render json: {'message' => 'Password length must be inbetween 8 to 16'} , status: :unprocessable_entity
			end
		end
	end

	def restaurant_user_create
		if user = User.find_by_email(params[:user][:email])
			render json: {'message' => 'Already signedup!'} , status: :ok
		else
			if params[:user][:password].blank?
				ident = params[:user][:identities_attributes]['0']
				p ident
				if ident[:provider].present? && ident[:uid].present? && ident[:token].present? 
					if user = User.create(user_params)
						user.role = 1
						user.verified = true
						user.save
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				else
					render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
				end
			elsif(params[:user][:password].length >= 8 && params[:user][:password].length <= 16)
				pass = BCrypt::Password.create(params[:user][:password])
				user = User.create(:email => params[:user][:email] , :encrypted_password => pass )
				identity = Identity.new(:provider => 'Dishcuss' , :user_id => user.id)
				identity.generate_token
			    identity.save
				render json: identity , serializer: UserTokenSerializer, status: :created
			else
				render json: {'message' => 'Password length must be inbetween 8 to 16'} , status: :unprocessable_entity
			end
		end
	end

	def signin
		p params
		if params[:user][:email].present? && ( params[:user][:email].length > 1 )
			p "Email Present"
			if user = User.find_by_email(params[:user][:email])
				p "User Found BY Email"
				if params[:user][:password].blank?
					p "User Password Blank"
					ident = params[:user][:identities_attributes]['0']
					if ident[:provider].present? && ident[:uid].present? && ident[:token].present? 
						p "Identity Present"
						if identity = user.identities.find_by_provider(ident[:provider])
							p "Found BY Provider"
							if identity.uid == ident[:uid]
								user.identities.each do |iden|
									iden.update_attributes(:token => nil)
								end
								identity.update_attributes(:token => ident[:token])
								p identity.inspect
					    		render json: identity , serializer: UserTokenSerializer, status: :ok
					    	else
					    		render json: {'message' => 'Invalid user id'} , status: :unprocessable_entity
					    	end
						else
							user.identities.each do |iden|
								iden.update_attributes(:token => nil)
							end
							identity = user.identities.create(user_signin_params["identities_attributes"]['0'])
							render json: identity , serializer: UserTokenSerializer,  status: :created
						end
					else
						render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
					end
				else
					if user.encrypted_password.present?
						p "Password Present"
						if BCrypt::Password.new(user.encrypted_password)  == params[:user][:password]
							if identity = user.identities.find_by_provider('Dishcuss')
								user.identities.each do |iden|
									iden.update_attributes(:token => nil)
								end
								identity.generate_token
					    		identity.save
					    		render json: identity , serializer: UserTokenSerializer, status: :ok
							else
								render json: {'message' => 'Failed to signin'} , status: :bad_request
							end
						else
							render json: {'message' => 'Invalid password!'} , status: :unauthorized
						end
					else
						render json: {'message' => 'Login to Social Sites'} , status: :bad_request
					end
				end
			elsif params[:user][:identities_attributes].present?
				p "Identity Present"
				ident = params[:user][:identities_attributes]['0']
				p ident
				if ident[:uid].present? && ident[:token].present? 
					p "User Create"
					if user = User.create(user_params)
						user.update(verified: true)
						user.generate_referral_code
						user.save
						cred = Credit.create(user_id: user.id)
						if params[:user][:referal_code].present?
							if u = User.find_by_referal_code(params[:user][:referal_code])
								user.referal_notification
								u.referal_sender_notification
							end
						end
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				else
					render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
				end	
			else
				render json: {'message' => 'Kindly signup!'} , status: :unauthorized
			end
		elsif params[:user][:identities_attributes].present?
			p "Identity Present But Not Email"
			ident = params[:user][:identities_attributes]['0']
			p ident
			if ident[:uid].present? && ident[:token].present? && ident[:provider].present? 
				if Identity.where(uid: ident[:uid]).where(provider: ident[:provider]).count > 0
					p "Identity Found"
					identity_t = Identity.where(uid: ident[:uid]).where(provider: ident[:provider])
					p "Identity"
					p identity_t.count
					identity_t.first.update(token: ident[:token])
					render json: identity_t.first , serializer: UserTokenSerializer,  status: :ok
				else
					p "Create New User"
					if user = User.create(user_params)
						user.update(verified: true)
						user.generate_referral_code
						user.save
						cred = Credit.create(user_id: user.id)
						if params[:user][:referal_code].present?
							if u = User.find_by_referal_code(params[:user][:referal_code])
								user.referal_notification
								u.referal_sender_notification
							end
						end
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				end
			else
				render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
			end	
		else
			render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
		end
	end

	def update
		p params
		user = @current_user
		if user.identities.where(provider: 'Dishcuss').count > 0
			user.update(user_update_pass_params)
		else
			user.update(user_update_params)
		end
		render json: user , serializer: UserUpSerializer , status: :ok
	end

	def signout
		@current_user.identities.each do |identity|
			if identity.token.present?
				identity.token = nil
				identity.save
			end
		end
		@current_user.gcm_devices.delete_all
		head :no_content
	end

	def verify_email
		#if v_user = User.find_by_email_verification_code(params[:token])
		#	if v_user.verified == true
		#		render json: {'message' => 'Email Already Verified!'} , status: :unprocessable_entity
		#	else
		#		v_user.update(verified: true)
		#		render json: {'message' => 'Email Successfully Verified!'} , status: :ok
		#	end
		#else
		#	render json: {'message' => 'Invalid Token!'} , status: :unauthorized
		#end

		if params[:token].to_i == 1234
			render json: {'message' => 'Email Already Verified!'} , status: :unprocessable_entity
		elsif params[:token].to_i == 5678
			render json: {'message' => 'Email Successfully Verified!'} , status: :ok
		else
			render json: {'message' => 'Invalid Token!'} , status: :unauthorized
		end
	end

	def follow
		if @current_user.id == params[:id]
			render json: {'message' => 'Cannot Follow yourself!'} , status: :unprocessable_entity
		elsif follows = User.find(params[:id])
			if @current_user.follows?(follows)
				render json: {'message' => 'Already followed!'} , status: :unprocessable_entity
			else
				@current_user.follow!(follows)
				if @current_user.newsfeed.present?
					@current_user.newsfeed.ids.push(params[:id])
					@current_user.newsfeed.save
				else
					news = Newsfeed.create(feed_id: @current_user.id , feed_type: 'User' , ids: [follows.id])
				end
				type = 'User'
				n = NotificationHelper.followed_notification(@current_user.id , follows.id , type)
				render json: {'message' => 'Successfully followed!'} , status: :ok
			end
		end
	end

	def unfollow
		user = @current_user
		if @current_user.id == params[:id]
			render json: {'message' => 'Cannot Unfollow yourself!'} , status: :unprocessable_entity
		elsif user.follows?(User.find(params[:id]))
			user.unfollow!(User.find(params[:id]))
			user.newsfeed.ids.delete(params[:id].to_i)
			user.newsfeed.save
			type = 'User'
			n = NotificationHelper.unfollowed_notification(@current_user.id , params[:id] , type)
			render json: {'message' => 'Successfully unfollowed!'} , status: :ok
		else
			render json: {'message' => 'User not followed!'} , status: :bad_request
		end
	end

	def followers
		user = @current_user
		follow =  user.followers(User)
		render json: follow , root: "users" , status: :ok
	end

	def likers
		if(params[:typee] == 'restaurant' || params[:typee] == 'food' || params[:typee] == 'post' || params[:typee] == 'review' || params[:typee] == 'comment')
			user=@current_user
			case params[:typee]
			when 'restaurant'
				type = 'Restaurant'
				likeme = Restaurant.find(params[:id])
				target_id = params[:id]
				#link = 'restaurant with id ' + params[:id]
				link = 'restaurant'
				us = likeme.owner
			when 'food'
				type = 'Restaurant'
				likeme = FoodItem.find(params[:id])
				target_id = likeme.menu.restaurant.id
				#link = 'food_item with id ' + params[:id]
				link = 'food item'
				us = likeme.section.menu.restaurant.owner
			when 'post'
				type = 'User'
				likeme = Post.find(params[:id])
				target_id = likeme.user.id
				#link = 'post with id ' + params[:id]
				link = 'post ***' + params[:id]
				us = likeme.user
			when 'review'
				likeme = Review.find(params[:id])
				type = 'User'
				target_id = likeme.reviewer_id
				#link = 'review with id ' + params[:id]
				link = 'review ***' + params[:id]
				us = likeme.reviewer
			when 'comment'
				likeme = Comment.find(params[:id])
				type = 'Comment'
				target_id = likeme.id
				#link = 'comment with id ' + params[:id]
				link = 'comment ***' + params[:id]
				us = likeme.user
			end
			if user.likes?(likeme)
				render json: {'message' => 'Already liked!'}, status: :unprocessable_entity
			else
				user.like!(likeme)
				if @current_user.id != us.id
					n = NotificationHelper.like_notification(user.id , target_id , type ,link)
				end
				render json: {'message' => 'Successfully liked!'} , status: :ok
			end
		else
			render json: {'message' => 'Invalid parameter'} , status: :unprocessable_entity
		end
	end

	def social
		if user = User.find(params[:id])
			render json: user , serializer: UserSocialSerializer , root: "user" , status: :ok
		end
	end

	def report
		if params[:type]=='review' || params[:type]=='comment' || params[:type]=='photo'
			case params[:type]
			when 'review'
				reportme = Review.find(params[:id])
				#link = 'review with id ' + params[:id]
				link = 'review'
				target_id = reportme.reviewable_id
				type = reportme.reviewable_type
				us = reportme.reviewer
			when 'comment'
				reportme = Comment.find(params[:id])
				#link = 'comment with id ' + params[:id]
				link = 'comment'
				target_id = reportme.id
				type = 'Comment'
				us = reportme.user
			when 'photo'
				reportme = Photo.find(params[:id])
				#link = 'photo with id ' + params[:id]
				link = 'photo'
				target_id = reportme.imageable_id
				type = reportme.imageable_type
				us = nil
			end
			report = Report.new(:reason => params[:reason] , reportable_id: params[:id])
			report.user_id = @current_user.id
			report.reportable_type = params[:type].titleize
			if report.save
				if us.nil? || ( us.id != @current_user.id )
					NotificationHelper.report_notification(@current_user.id , target_id , type ,link)
				end
				render json: report , serializer: ReportSerializer , status: :created
			else
				render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
			end
		else
			render json: {'message' => 'Bad Request'} , status: :bad_request
		end
	end

	def message
		restaurant = Restaurant.find(params[:id])
		message = Message.new(:body => params[:body] , :restaurant_id => restaurant.id , :user_id => @current_user.id)
		if message.save
			render json: message , serializer: MessageSerializer , status: :created
		else
			render json: {'message' => 'Unprocessable Entity'} , status: :unprocessable_entity
		end
	end

	def dislike
		if(params[:typee] == 'restaurant' || params[:typee] == 'food' || params[:typee] == 'post' || params[:typee] == 'review')
			user=@current_user
			case params[:typee]
			when 'restaurant'
				type = 'Restaurant'
				likeme = Restaurant.find(params[:id])
				target_id = params[:id]
				#link = 'restaurant with id ' + params[:id]
				link = 'restaurant'
			when 'food'
				type = 'Restaurant'
				likeme = FoodItem.find(params[:id])
				target_id = likeme.menu.restaurant.id
				#link = 'food_item with id ' + params[:id]
				link = 'food item'
			when 'post'
				type = 'User'
				likeme = Post.find(params[:id])
				target_id = likeme.user.id
				#link = 'post with id ' + params[:id]
				link = 'post'
			when 'review'
				likeme = Review.find(params[:id])
				type = likeme.reviewable_type
				target_id = likeme.reviewable.id
				#link = 'review with id ' + params[:id]
				link = 'review'
			end
			if user.likes?(likeme)
				render json: {'message' => 'You have liked that item!'}, status: :unprocessable_entity
			else
				if Dislike.where(dislikeable_id: likeme.id , dislikeable_type: likeme.class.name , disliker_id: user.id).count > 0
					render json: {'message' => 'Already disliked!'} , status: :unprocessable_entity
				else
					Dislike.create(dislikeable_id: likeme.id , dislikeable_type: likeme.class.name , disliker_id: user.id)
					n = NotificationHelper.dislike_notification(user.id , target_id , type ,link)
					render json: {'message' => 'Successfully disliked!'} , status: :ok
				end
			end
		else
			render json: {'message' => 'Invalid parameter'} , status: :unprocessable_entity
		end
	end

	def my_feeds
		us = []
		user = User.order(followers_count: :desc).each do |user|
			if user != @current_user
				if user.dp.present?
					k = user.dp.url
				else
					k = user.avatar
				end 
				us.push({id: user.id , name: user.name , username: user.username , avatar: k , location: user.location , follows: @current_user.follows?(user) , followers: user.followers_count})
			end
		end
		render json: { "users" => us }, status: :ok
	end

	def notifications
		noti = @current_user.notifications.where(seen: false).order(created_at: 'DESC')
		#noti = Notification.all.order(created_at: 'DESC')
		render json: noti , root: "users" , status: :ok
	end

	def notification_seen
		notif = @current_user.notifications.where(seen: false)
		notif.each do |noti|
			noti.update(seen: true)
		end
		render json: {'message' => 'Notification Seen'} , status: :ok
	end

	def get_users
		iden = @current_user.identities.where.not(token: nil).first
		ident = Identity.where(provider: iden.provider).where.not(token: iden.token)
		render json: ident , each_serializer: IdentityUserSerializer , root: "users" , status: :ok
	end

	def get_user_likes
		res = Like.where(liker_type: 'User').where(liker_id: @current_user.id).where(likeable_type: 'Restaurant')
		render json: res , each_serializer: LikeRestaurantSerializer , root: 'restaurant' , status: :ok
	end

	def chk_follow_user
		user = @current_user
		ch_user = User.where(id: params[:id])
		if ch_user.count > 0
			chk = user.follows?(ch_user.first)
			render json: {'follows' => chk} , status: :ok
		else
			render json: {'message' => 'User not found'} , status: :unprocessable_entity
		end
	end

	def update_picture
		p params
		if params[:user][:avatar].present?
			p @current_user.dp.url
			@current_user.update(dp: params[:user][:avatar])
			p @current_user.dp.url
			identity = @current_user.identities.where.not(token: nil).first
			render json: identity , serializer: UserTokenSerializer , root: 'user' , status: :ok
		else
			render json: {'message' => 'Image missing'} , status: :unprocessable_entity
		end
	end

	def unlike
		if (params[:typee] == 'post' || params[:typee] == 'review' || params[:typee] == 'comment')
			if params[:typee] == 'post'
				if @current_user.likes?(Post.find(params[:id]))
					@current_user.unlike!(Post.find(params[:id]))
					c = 'Successfully unliked!'
				else
					c = 'Like post first!'
				end
			elsif params[:typee] == 'review'
				if @current_user.likes?(Review.find(params[:id]))
					@current_user.unlike!(Review.find(params[:id]))
					c = 'Successfully unliked!'
				else
					c = 'Like review first!'
				end
			elsif params[:typee] == 'comment'
				if @current_user.likes?(Comment.find(params[:id]))
					@current_user.unlike!(Comment.find(params[:id]))
					c = 'Successfully unliked!'
				else
					c = 'Like comment first!'
				end
			end
			render json: {'message' => c} , status: :ok
		else
			render json: {'message' => 'Missing Parameter'} , status: :unprocessable_entity
		end
	end

	private
	def user_params
		params.require(:user).permit(:name, :username, :email, :password, :avatar, :location, :gender, :referal_code , identities_attributes: [:provider, :uid, :url, :token, :expires_at])
	end

	def user_signin_params
		params.require(:user).permit(:email, :password, identities_attributes: [:provider, :uid, :url, :token, :expires_at])
	end

	def user_create_params
		params.require(:user).permit(:name, :username, :location, :dob , :gender)
	end

	def user_update_pass_params
		params.require(:user).permit(:name, :location, :dob , :gender , :password)
	end

	def user_update_params
		params.require(:user).permit(:name, :location, :dob , :gender)
	end

end
