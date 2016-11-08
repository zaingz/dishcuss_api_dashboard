class ReviewsController < ApplicationController
	before_filter :restrict_access , except: [:get_review]
	before_filter :is_end_user , except: [:get_review]

	def create_restaurant_review
		p params
		review = Review.new(review_params)
		#review.reviewable_id = params[:review][:reviewable_id]
		type = 'Restaurant'
		review.reviewable_type = 'Restaurant'
		review.reviewer_id = @current_user.id
		if review.save
			#credit on review
			ck = true
			if params[:review][:share_id].present?
				if po = Review.find_by_id(params[:review][:share_id])
					po.shares = po.shares + 1
					po.save
					p "incresing share count for review"
					ck = false
				end
			end

			coun = Review.where(reviewer_id: @current_user.id).where(reviewable_type: 'Restaurant').where(reviewable_id: params[:review][:reviewable_id]).count
			p coun
			c = Restaurant.find(params[:review][:reviewable_id]).owner
			if coun == 1 && ck
				p "mazay a gaye"
				if @current_user.id != c.id
					CreditHelper.review_credit(@current_user.id)
					NotificationHelper.credit_notification(@current_user.id , 'review')
				end
			end
			if params[:review][:rating].present?
				rato = Rating.create(rate: params[:review][:rating] , restaurant_id: params[:review][:reviewable_id] , user_id: @current_user.id)
			end
			#link = 'restaurant with id ' + params[:review][:reviewable_id]
			link = 'restaurant'
			if @current_user.id != c.id
				n = NotificationHelper.review_notification(@current_user.id , params[:review][:reviewable_id] , type , link)
			end
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
			u = User.find(params[:review][:reviewable_id])
			if coun == 1
				p "mazay a gaye"
				if @current_user.id != u.id
					CreditHelper.review_credit(@current_user.id)
					NotificationHelper.credit_notification(@current_user.id , 'review')
				end
			end
			#link = 'user with id ' + params[:review][:reviewable_id]
			link = 'user'
			if @current_user.id != u.id
				n = NotificationHelper.review_notification(@current_user.id , params[:review][:reviewable_id] , type , link)
			end
			render json: review , status: :created
		else
			render json: {'message' => 'unprocessable entitty'} , status: :unprocessable_entity
		end
	end


	def comment
		commentable = Review.find(params[:id])
		comment = commentable.comments.create
		comment.title = params[:title]
		comment.comment = params[:comment]
		comment.user_id = @current_user.id
		if comment.save
			if params[:image].blank?
			else
				photo = Photo.create(:image => params[:image].first, :imageable_id => comment.id , :imageable_type => 'Comment')
			end
			target_id = commentable.reviewable_id
			type = commentable.reviewable_type
			#link = 'review with id ' + params[:id]
			link = 'review ***' + params[:id]
			if target_id != @current_user.id
				n = NotificationHelper.comment_notification(@current_user.id , target_id , type ,link)
			end
			if commentable.reviewer_id != @current_user.id
				n = NotificationHelper.comment_notification(@current_user.id , commentable.reviewer_id , 'User' ,link)
			end
			ara = commentable.comments.pluck(:user_id).uniq
			ara.each do |num|
				if @current_user.id != num
					as = commentable.reviewer.username
					cv = @current_user.username + ' commented on ' + as + "'s review ***"+ params[:id]
					Notification.create(:notifier_id => @current_user.id  , :target_id => num , :target_type => 'User' , :body => cv )
				end
			end
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

	def get_review
		if review = Review.find_by_id(params[:id])
			ue = nil
			has = request.headers.env.select{|k, _| k =~ /^HTTP_/}
			if has["HTTP_AUTHORIZATION"].present?
				a = has["HTTP_AUTHORIZATION"].split('Token token=')[1]
				iden = Identity.find_by_token(a)
				if iden
					ue = iden.user
				end
			end
			render json: review , serializer: ReviewLikeSerializer , root: 'review' , scope: {option_name: ue} , status: :ok
		else
			render json: {'message' => 'Review is missing'} , status: :bad_request
		end
	end


	private
	def review_params
		params.require(:review).permit( :title , :summary , :rating , :reviewable_id)
	end
end
