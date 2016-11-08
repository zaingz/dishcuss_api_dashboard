class PostsController < ApplicationController
	before_filter :restrict_access , except: [:get_post]
	before_filter :is_end_user , except: [:get_post]

	def index
		user = @current_user
		render json:user.posts , status: :ok
	end

	def update
		if post = @current_user.posts.find(params[:id])
			post.update(post_update_params)
			if params[:post][:image].present?
				if params[:post][:photo_id].present? && params[:post][:image].count==1
					p = post.photos.find(params[:post][:photo_id])
					
					p.update image: params[:post][:image].first
				else
					params[:post][:image].each do |a|
	            		photo = Photo.create(:image => a, :imageable_id => post.id , :imageable_type => 'Post')
	          		end
	          	end
			end
			render json: {'message' => 'Post successfully updated!'} , status: :ok
		end
	end

	def destroy
		if post = @current_user.posts.find(params[:id])
			post.destroy
			head :no_content
		end
	end

	def create
		p "Params for post " + post_params.inspect
		if post = Post.create(post_params)
			post.user_id = @current_user.id
			post.save

			ck = true
			if params[:post][:share_id].present?
				if po = Post.find_by_id(params[:post][:share_id])
					po.shares = po.shares + 1
					po.save
					p "incresing share count for post"
					ck = false
				end
			end
			
			p "Image Params " + params[:image].inspect
			if params[:post][:image].present?
				params[:post][:image].each do |a|
	            	photo = Photo.create(:image => a, :imageable_id => post.id , :imageable_type => 'Post')
	          	end
	        end
	        if params[:post][:checkin_attributes].present?
		        if params[:post][:checkin_attributes][:address].present?
		        	chk_checkin = false
		        	chk_checkin_count = 0
		        	@current_user.posts.order(created_at: 'DESC').each do |posti|
		        		if posti.checkin.present?
		        			if ( posti.checkin.created_at + 1.day ) > Time.now 
		        				chk_checkin = true
		        				chk_checkin_count = chk_checkin_count + 1
		        			end
		        		end
		        	end
		        	if chk_checkin == true && chk_checkin_count <= 3 && ck
		        		p "Credit mil gya"
			        	ch = CreditHelper.checkin_credit(@current_user.id , params[:post][:checkin_attributes][:address])
			        	if ch
			        		cn = NotificationHelper.credit_notification(@current_user.id , 'checkin')
			        	end
			        else
			        	p chk_checkin
			        	p chk_checkin_count
			        end
		        end
		    end
			render json: post , status: :created
		else
			render json: {"message:" => "Unprocessable entity"}, status: :unprocessable_entity
		end
	end

	def likeable
		post = Post.find(params[:id])
		user = post.likers(User)
		render json: user , root: "posts", status: :ok
	end

	def comment
		commentable = Post.find(params[:id])
		comment = commentable.comments.create
		comment.title = params[:title]
		comment.comment = params[:comment]
		comment.user_id = @current_user.id
		if comment.save
			if params[:image].present? && params[:image].count==1
				photo = Photo.create(:image => params[:image].first, :imageable_id => comment.id , :imageable_type => 'Comment')
			end
			target_id = commentable.user_id
			type = 'User'
			#link = 'post with id ' + params[:id]
			link = 'post ***' + params[:id]
			if target_id != @current_user.id
				n = NotificationHelper.comment_notification(@current_user.id , target_id , type ,link)
			end
			ara = commentable.comments.pluck(:user_id).uniq
			ara.each do |num|
				if @current_user.id != num
					as = commentable.user.username
					cv = @current_user.username + ' commented on ' + as + "'s post ***" + params[:id]
					Notification.create(:notifier_id => @current_user.id  , :target_id => num , :target_type => 'User' , :body => cv )
				end
			end
			render json: comment , status: :created
		else
			render json: {"message:" => "Unprocessable entity"}, status: :unprocessable_entity
		end
	end

	def showcomment
		commentable = Post.find(params[:id])
		comments = commentable.comments.recent.limit(10).all
		if comments.present?
			render json: comments , root: "posts" , status: :ok
		else
			render json: {'message' => 'Post has no comments'} , status: :bad_request
		end
	end

	def get_post
		if post = Post.find_by_id(params[:id])
			ue = nil
			has = request.headers.env.select{|k, _| k =~ /^HTTP_/}
			if has["HTTP_AUTHORIZATION"].present?
				a = has["HTTP_AUTHORIZATION"].split('Token token=')[1]
				iden = Identity.find_by_token(a)
				if iden
					ue = iden.user
				end
			end
			render json: post , serializer: PostLikeSerializer , root: 'post' , scope: {option_name: ue}  , status: :ok
		else
			render json: {'message' => 'Post is missing'} , status: :bad_request
		end
	end


	private
	def post_params
		params.require(:post).permit(:title, :status  , :image , checkin_attributes: [:address , :lat , :long , :restaurant_id])
	end

	def post_update_params
		params.require(:post).permit(:title, :status  , :image , :photo_id , checkin_attributes: [:address , :lat , :long , :restaurant_id])
	end
end
