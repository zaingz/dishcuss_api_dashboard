class UsersController < ApplicationController
	#before_action :authenticate , :except => [:create]
	before_filter :restrict_access, except: [:create , :signin ,:restaurant_user_create , :verify_email]
	before_filter :is_end_user, except: [:create , :signin , :social ,:restaurant_user_create , :signout , :verify_email , :notifications , :update] 

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
						#:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email],  :avatar => params[:avatar], :location => params[:location], :gender => params[:gender]
						#@identity = Identity.create(:provider => params[:provider], :uid => params[:uid], :url => params[:url], :token => params[:token], :expires_at => params[:expires_at] , :user_id => @user.id)
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				else
					render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
				end
			else
				pass = BCrypt::Password.create(params[:user][:password])
				user = User.create( email: params[:user][:email] , :password => pass )
				user.update(user_create_params)
				user.generate_referral_code
				user.save
				cred = Credit.create(user_id: user.id)
				identity = Identity.new(:provider => 'Dishcuss' , :user_id => user.id)
				identity.generate_token
			    identity.save
				render json: identity , serializer: UserTokenSerializer, status: :created
				UserMailer.welcome_email(user).deliver_later
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
						#:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email],  :avatar => params[:avatar], :location => params[:location], :gender => params[:gender]
						#@identity = Identity.create(:provider => params[:provider], :uid => params[:uid], :url => params[:url], :token => params[:token], :expires_at => params[:expires_at] , :user_id => @user.id)
						render json: user.identities.first , serializer: UserTokenSerializer,  status: :created
					else
						render json: user.errors, status: :unprocessable_entity
					end
				else
					render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
				end
			else
				pass = BCrypt::Password.create(params[:user][:password])
				user = User.create(:email => params[:user][:email] , :password => pass )
				identity = Identity.new(:provider => 'Dishcuss' , :user_id => user.id)
				identity.generate_token
			    identity.save
				render json: identity , serializer: UserTokenSerializer, status: :created
				UserMailer.welcome_email(user).deliver_later
			end
		end
	end

	def signin
		if params[:user][:email].present?
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
							#:provider => params[:provider], :uid => params[:uid], :url => params[:url], :token => params[:token], :expires_at => params[:expires_at] , :user_id => @user.id
							render json: identity , serializer: UserTokenSerializer,  status: :created
						end
					else
						render json: {'message' => 'Params are missing!'} , status: :unprocessable_entity
					end
				else
					if user.password.present?
						p "Password Present"
						if BCrypt::Password.new(user.password)  == params[:user][:password]
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
						#:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email],  :avatar => params[:avatar], :location => params[:location], :gender => params[:gender]
						#@identity = Identity.create(:provider => params[:provider], :uid => params[:uid], :url => params[:url], :token => params[:token], :expires_at => params[:expires_at] , :user_id => @user.id)
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
						#:first_name => params[:first_name], :last_name => params[:last_name], :email => params[:email],  :avatar => params[:avatar], :location => params[:location], :gender => params[:gender]
						#@identity = Identity.create(:provider => params[:provider], :uid => params[:uid], :url => params[:url], :token => params[:token], :expires_at => params[:expires_at] , :user_id => @user.id)
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
		head :no_content
	end

	def verify_email
		if identity = Identity.find_by_token(params[:token])
			v_user = identity.user
			if v_user.verified == true
				render json: {'message' => 'Email Already Verified!'} , status: :unprocessable_entity
			else
				v_user.update(verified: true)
				render json: {'message' => 'Email Successfully Verified!'} , status: :ok
			end
		else
			render json: {'message' => 'Invalid Token!'} , status: :unauthorized
		end
	end

	def follow
		if follows = User.find(params[:id])
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
		@user = @current_user
		if @user.follows?(User.find(params[:id]))
			@user.unfollow!(User.find(params[:id]))
			@user.newsfeed.ids.delete(params[:id].to_i)
			@user.newsfeed.save
			type = 'User'
			n = NotificationHelper.unfollowed_notification(@current_user.id , params[:id] , type)
			render json: {'message' => 'Successfully unfollowed!'} , status: :ok
		else
			render json: {'message' => 'User not followed!'} , status: :bad_request
		end
	end

	def followers
		@user = @current_user
		@follow =  @user.followers(User)
		render json: @follow , status: :ok
	end

	def likers
		if(params[:typee] == 'restaurant' || params[:typee] == 'food' || params[:typee] == 'post' || params[:typee] == 'review' || params[:typee] == 'comment')
			@user=@current_user
			case params[:typee]
			when 'restaurant'
				type = 'Restaurant'
				likeme = Restaurant.find(params[:id])
				target_id = params[:id]
				link = 'restaurant with id ' + params[:id]

			when 'food'
				type = 'Restaurant'
				likeme = FoodItem.find(params[:id])
				target_id = likeme.menu.restaurant.id
				link = 'food_item with id ' + params[:id]
			when 'post'
				type = 'User'
				likeme = Post.find(params[:id])
				target_id = likeme.user.id
				link = 'post with id ' + params[:id]
			when 'review'
				likeme = Review.find(params[:id])
				type = likeme.reviewable_type
				target_id = likeme.reviewable.id
				link = 'review with id ' + params[:id]
			when 'comment'
				likeme = Comment.find(params[:id])
				type = 'Comment'
				target_id = likeme.id
				link = 'comment with id ' + params[:id]
			end
			if @user.likes?(likeme)
				render json: {'message' => 'Already liked!'}, status: :unprocessable_entity
			else
				@user.like!(likeme)
				n = NotificationHelper.like_notification(@user.id , target_id , type ,link)
				render json: {'message' => 'Successfully liked!'} , status: :ok
			end
		else
			render json: {'message' => 'Invalid parameter'} , status: :unprocessable_entity
		end
	end

	def social
		if user = User.find(params[:id])
			render json: user , serializer: UserSocialSerializer , status: :ok
		end
	end

	def report
		if params[:type]=='review' || params[:type]=='comment' || params[:type]=='photo'
			case params[:type]
			when 'review'
				reportme = Review.find(params[:id])
				link = 'review with id ' + params[:id]
				target_id = reportme.reviewable_id
				type = reportme.reviewable_type
			when 'comment'
				reportme = Comment.find(params[:id])
				link = 'comment with id ' + params[:id]
				target_id = reportme.id
				type = 'Comment'
			when 'photo'
				reportme = Photo.find(params[:id])
				link = 'photo with id ' + params[:id]
				target_id = reportme.imageable_id
				type = reportme.imageable_type
			end
			report = Report.new(:reason => params[:reason] , reportable_id: params[:id])
			report.user_id = @current_user.id
			report.reportable_type = params[:type].titleize
			if report.save
				NotificationHelper.report_notification(@current_user.id , target_id , type ,link)
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
			@user=@current_user
			case params[:typee]
			when 'restaurant'
				type = 'Restaurant'
				likeme = Restaurant.find(params[:id])
				target_id = params[:id]
				link = 'restaurant with id ' + params[:id]

			when 'food'
				type = 'Restaurant'
				likeme = FoodItem.find(params[:id])
				target_id = likeme.menu.restaurant.id
				link = 'food_item with id ' + params[:id]
			when 'post'
				type = 'User'
				likeme = Post.find(params[:id])
				target_id = likeme.user.id
				link = 'post with id ' + params[:id]
			when 'review'
				likeme = Review.find(params[:id])
				type = likeme.reviewable_type
				target_id = likeme.reviewable.id
				link = 'review with id ' + params[:id]
			end
			if @user.likes?(likeme)
				render json: {'message' => 'You have liked that item!'}, status: :unprocessable_entity
			else
				if Dislike.where(dislikeable_id: likeme.id , dislikeable_type: likeme.class.name , disliker_id: @user.id).count > 0
					render json: {'message' => 'Already disliked!'} , status: :unprocessable_entity
				else
					Dislike.create(dislikeable_id: likeme.id , dislikeable_type: likeme.class.name , disliker_id: @user.id)
					n = NotificationHelper.dislike_notification(@user.id , target_id , type ,link)
					render json: {'message' => 'Successfully disliked!'} , status: :ok
				end
			end
		else
			render json: {'message' => 'Invalid parameter'} , status: :unprocessable_entity
		end
	end

	def my_feeds
		us = []
		user = User.order(followees_count: :desc).each do |user|
			us.push({id: user.id , name: user.name , username: user.username , avatar: user.avatar , location: user.location , follows: @current_user.follows?(user) , followers: user.followers_count})
		end
		render json: us , status: :ok
	end

	def notifications
		noti = @current_user.notifications.where(seen: false).order(created_at: 'DESC')
		render json: noti , status: :ok
	end

	def notification_seen
		notif = @current_user.notifications.find(params[:id])
		if notif.seen
			render json: {'message' => 'Already Seen'} , status: :unprocessable_entity
		else
			notif.update(seen: true)
			render json: {'message' => 'Notification Seen'} , status: :ok
		end
	end

	def get_users
		iden = @current_user.identities.where.not(token: nil).first
		ident = Identity.where(provider: iden.provider).where.not(token: iden.token)
		render json: ident , each_serializer: IdentityUserSerializer , status: :ok
	end

	private
	def user_params
		params.require(:user).permit(:name, :username, :email, :password, :avatar, :location, :gender, identities_attributes: [:provider, :uid, :url, :token, :expires_at])
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
