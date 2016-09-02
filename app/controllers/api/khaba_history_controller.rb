class KhabaHistoryController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def index
		khaba = CreditHistory.where(user_id: @current_user.id).order(updated_at: 'DESC')
		render json: khaba , each_serializer: KhabaHistorySerializer , root: "khaba_history"  , status: :ok
	end

	def credit
		credit = @current_user.credit
		used = 0
		CreditHistory.where(user_id: @current_user.id).each do |cre_his|
			used = used + cre_his.price
		end
		cres = Hash.new
		cres["credit"] = Hash.new
		cres["credit"]["total_credits"] = used + credit.points
		cres["credit"]["used_credits"] = used
		cres["credit"]["balance"] = credit.points
		render json: cres , status: :ok
	end
end
