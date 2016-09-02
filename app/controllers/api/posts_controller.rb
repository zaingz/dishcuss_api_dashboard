class PostsController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def index
		@user = @current_user
		render json:@user.posts , status: :ok
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
	            		@photo = Photo.create(:image => a, :imageable_id => post.id , :imageable_type => 'Post')
	          		end
	          	end
			end
			render json: {'message' => 'Post successfully updated!'} , status: :ok
		end
	end

	def destroy
		if @post = @current_user.posts.find(params[:id])
			@post.destroy
			head :no_content
		end
	end

	def create
		p "Params for post " + post_params.inspect
		if @post = Post.create(post_params)
			@post.user_id = @current_user.id
			@post.save
			
			p "Image Params " + params[:image].inspect
			if params[:post][:image].present?
				params[:post][:image].each do |a|
	            	@photo = Photo.create(:image => a, :imageable_id => @post.id , :imageable_type => 'Post')
	          	end
	        end
	        if params[:post][:checkin_attributes][:address].present?
	        	ch = CreditHelper.checkin_credit(@current_user.id , params[:post][:checkin_attributes][:address])
	        	if ch
	        		NotificationHelper.credit_notification(@current_user.id , 'checkin')
	        	end
	        end
			render json: @post , status: :created
		else
			render json: {"message:" => "Unprocessable entity"}, status: :unprocessable_entity
		end
	end

	def likeable
		post = Post.find(params[:id])
		user = post.likers(User)
		render json: user , status: :ok
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
			link = 'post with id ' + params[:id]
			n = NotificationHelper.comment_notification(@current_user.id , target_id , type ,link)
			render json: comment , status: :created
		else
			render json: {"message:" => "Unprocessable entity"}, status: :unprocessable_entity
		end
	end

	def showcomment
		commentable = Post.find(params[:id])
		comments = commentable.comments.recent.limit(10).all
		if comments.present?
			render json: comments , status: :ok
		else
			render json: {'message' => 'Post has no comments'} , status: :bad_request
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
