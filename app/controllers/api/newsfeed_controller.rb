class NewsfeedController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def index
		@user = @current_user
		if @user.newsfeed.present?
			tot_review = Hash.new
		    tot_review["Review"] =  [] 
		    tot_review["Checkin"] = []
			@user.newsfeed.ids.each do |use|
				Review.where(reviewer_id: use).each do |review|
					#my_obj = review.merge(review.reviewable)
					#tot_review.push({review: review})
					#hash = {}
					#tem = ActiveModel::ArraySerializer.new(review, each_serializer: ReviewSerializer)
					#p tem
					#tem.instance_variables.each {|var| hash[var.to_s.delete("@")] = tem.instance_variable_get(var) }
					tot_review["Review"] << review
					#JSON.parse(hash.to_json)
				end
				Post.where(user_id: use).each do |post|
					if post.checkin.present?
						#tot_review.push(post)
						#hash = {}
						#tem = ActiveModel::ArraySerializer.new(post, each_serializer: PostSerializer)
						#p tem
						#tem.instance_variables.each {|var| hash[var.to_s.delete("@")] = tem.instance_variable_get(var) }
						tot_review["Checkin"] << post
						#JSON.parse(hash.to_json)
					end
				end
			end
			p tot_review
			render json: {review: ActiveModel::ArraySerializer.new(tot_review['Review'], each_serializer: ReviewSerializer), checkin: ActiveModel::ArraySerializer.new(tot_review['Checkin'], each_serializer: PostSerializer)}  , status: :ok
		else
			render json: {'message' => 'Newsfeed missing'} , status: :unprocessable_entity
		end
	end

end