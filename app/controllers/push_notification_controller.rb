class PushNotificationController < ApplicationController
	before_filter :restrict_access
	#before_filter :is_end_user

	def set_key
		p params
		if c = @current_user.gcm_devices.find_by_device(params[:device])
			c.update(token: params[:token])
		else
			c = GcmDevice.create(token: params[:token] , device: params[:device] , user_id: @current_user.id)
		end
		render json: {'token' => params[:token] , 'device' => params[:device]} , status: :ok
	end

	def send_push
		require 'gcm'
		gcm = GCM.new("AIzaSyDFOzJaBECT3D0L2ub0NX94T9h4ygkGyVY")
		registration_ids= @current_user.gcm_devices.pluck(:token) # an array of one or more client registration tokens
		options = {data: {score: "123"}, collapse_key: "Notification"}
		response = gcm.send(registration_ids, options)

		apn = Houston::Client.development
	    apn.certificate = File.read("#{Rails.root}/config/requried.pem") # certificate from prerequisites
	   	apn.passphrase = "123456"
	   	@current_user.gcm_devices.where(device: 'ios').each do |tok|
	      notification = Houston::Notification.new(device: tok.token)
	      notification.alert = 'message here'
	      # take a look at the docs about these params
	      notification.badge = 1
	      notification.sound = "sosumi.aiff"
	      notification.custom_data = {data: {message: 'message here' , title: 'DishCuss' , redirect_id: 126 , redirect_type: 'Post' }, title_e: "DishCuss"}
	      apn.push(notification)
	    end
	    render json: {'message' => 'Success!'} , status: :ok
	end

	def notifications
		noti = @current_user.notifications.order(created_at: 'ASC')
		#noti = Notification.all.order(created_at: 'DESC')
		render json: noti , root: 'users', status: :ok
	end
end
