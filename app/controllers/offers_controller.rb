class OffersController < ApplicationController
	before_filter :restrict_access
	before_filter :is_end_user

	def index
		qrcode = Qrcode.all.order(updated_at: 'DESC')
		render json: qrcode , each_serializer: OffersSerializer , root: "offers"  , status: :ok
	end
end
