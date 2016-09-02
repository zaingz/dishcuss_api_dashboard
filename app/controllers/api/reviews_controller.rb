class ReviewsController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def create_restaurant_review
		review = Review.new(review_params)
		#review.reviewable_id = params[:review][:reviewable_id]
		type = 'Restaurant'
		review.reviewable_type = 'Restaurant'
		review.reviewer_id = @current_user.id
		if review.save
			#credit on review
			coun = Review.where(reviewer_id: @current_user.id).where(reviewable_type: 'Restaurant').where(reviewable_id: params[:review][:reviewable_id]).count
			p coun
			if coun == 1
				p "mazay a gaye"
				CreditHelper.review_credit(@current_user.id)
				NotificationHelper.credit_notification(@current_user.id , 'review')
			end
			link = 'restaurant with id ' + params[:review][:reviewable_id]
			n = NotificationHelper.review_notification(@current_user.id , params[:review][:reviewable_id] , type , link)
			render json: review , status: :created
		else
			render json: {'message' => 'unprocessable entitty'} , status: :unprocessable_entity
		end
	end

	def create_user_review
		review = Review.new(review_params)
		#review.reviewable_id = params[:review][:reviewable_id]
		review.reviewable_type = 'User'
		type = 'User'
		review.reviewer_id = @current_user.id
		if review.save
			#credit on review
			coun = Review.where(reviewer_id: @current_user.id).where(reviewable_type: 'User').where(reviewable_id: params[:review][:reviewable_id]).count
			p coun
			if coun == 1
				p "mazay a gaye"
				CreditHelper.review_credit(@current_user.id)
				NotificationHelper.credit_notification(@current_user.id , 'review')
			end
			link = 'user with id ' + params[:review][:reviewable_id]
			n = NotificationHelper.review_notification(@current_user.id , params[:review][:reviewable_id] , type , link)
			render json: review , status: :created
		else
			render json: {'message' => 'unprocessable entitty'} , status: :unprocessable_entity
		end
	end



	#def likeable
	#	@review = Review.find(params[:id])
	#	@review.likers(User).each do |user|
	#		render json: ("first_name: " + user.first_name + ", last_name: " + user.last_name) , status: :ok
	#	end
	#end

	def comment
		commentable = Review.find(params[:id])
		comment = commentable.comments.create
		comment.title = params[:title]
		comment.comment = params[:comment]
		comment.user_id = @current_user.id
		if comment.save
			if params[:image].blank?
			else
				@photo = Photo.create(:image => params[:image].first, :imageable_id => comment.id , :imageable_type => 'Comment')
			end
			target_id = commentable.reviewable_id
			type = commentable.reviewable_type
			link = 'review with id ' + params[:id]
			n = NotificationHelper.comment_notification(@current_user.id , target_id , type ,link)
			render json: comment , status: :created
		else
			render json: {"message:" => "Unprocessable entity"}, status: :unprocessable_entity
		end
	end

	def showcomment
		commentable = Review.find(params[:id])
		comments = commentable.comments.recent.limit(10).all
		if comments.present?
			render json: comments , status: :ok
		else
			render json: {'message' => 'Review has no comments'} , status: :bad_request
		end
	end


	private
	def review_params
		params.require(:review).permit( :title , :summary , :rating , :reviewable_id)
	end
end
