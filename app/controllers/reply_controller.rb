class ReplyController < ApplicationController
	before_filter :restrict_access
	#before_filter :is_end_user

	def reply_to_comment
		if c = Comment.exists?(params[:id])
			if params[:reply].present?
				cs = Comment.create(comment: params[:reply] , commentable_type: 'Comment' , commentable_id: params[:id] , user_id: @current_user.id)
				render json: cs , root: "reply" , status: :ok
			else
				render json: {'message' => 'Reply Missing!'} , status: :unprocessable_entity
			end
		else
			render json: {'message' => 'Cannot find comment'} , status: :unprocessable_entity 
		end
	end
end
