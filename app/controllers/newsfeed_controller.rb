class NewsfeedController < ApplicationController
	before_filter :restrict_access , except: [:localfeed_updated]
	before_filter :is_end_user , except: [:localfeed_updated]

	def index
		user = @current_user
		if user.newsfeed.present?
			tot_review = Hash.new
		    tot_review["Review"] =  [] 
		    tot_review["Checkin"] = []
		    days_for_review = 30
		    days_less = Time.now
		    count = 0
		    while((tot_review["Review"].length + tot_review["Checkin"].length) < 40 && count < 11)
				#user.newsfeed.ids.each do |use|
					Review.where(reviewer_id: user.newsfeed.ids).where("created_at >= ?", days_for_review.days.ago).where("created_at < ?", days_less).each do |review|
						tot_review["Review"] << ReviewUserSerializer.new(review , scope: {option_name: @current_user} )
					end
					Post.where(user_id: user.newsfeed.ids).where("created_at >= ?", days_for_review.days.ago).where("created_at < ?", days_less).each do |post|
						tot_review["Checkin"] << PostUserSerializer.new(post , scope: {option_name: @current_user})
					end
				#end
				#user.newsfeed.rest_ids.each do |use|
					Review.where(reviewable_type: 'Restaurant').where(reviewable_id: user.newsfeed.rest_ids).where("created_at >= ?", days_for_review.days.ago).where("created_at < ?", days_less).each do |review|
						tot_review["Review"] << ReviewUserSerializer.new(review , scope: {option_name: @current_user} )
					end
				#end
				count = count + 1
				days_less = days_less + days_for_review.days
				days_for_review = days_for_review + 1
			end
			render json: {review: tot_review["Review"] , checkin: tot_review["Checkin"] }  , status: :ok
		else
			render json: {'message' => 'Newsfeed missing'} , status: :unprocessable_entity
		end
	end

	def localfeed_updated
		tot_review = Hash.new
	    tot_review["Checkin"] = []
	    tot_review["Review"] = []
	    offseti = 0
	    if params[:offset].present?
	    	offseti = params[:offset]
	    end

	    ue = nil
		has = request.headers.env.select{|k, _| k =~ /^HTTP_/}
		if has["HTTP_AUTHORIZATION"].present?
			a = has["HTTP_AUTHORIZATION"].split('Token token=')[1]
			iden = Identity.find_by_token(a)
			if iden
				ue = iden.user
			end
		end

		rev = Review.all.order(created_at: 'DESC').limit(5).offset(offseti)
		rev.each do |revie|
			tot_review["Review"] << ReviewUserSerializer.new(revie , scope: {option_name: ue} )
		end
		Post.all.order(created_at: 'DESC').limit(5).offset(offseti).each do |post|
			tot_review["Checkin"] << PostUserSerializer.new(post , scope: {option_name: ue})
		end
		p tot_review
		render json: {review: tot_review["Review"] , checkin: tot_review['Checkin'] }  , status: :ok
	end

end