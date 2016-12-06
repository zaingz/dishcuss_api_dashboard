class Notification < ActiveRecord::Base
	belongs_to :target, :polymorphic => true
	belongs_to :notifier, :class_name => 'User'

	after_create :gcm

	def gcm
		if self.target_type == 'User'
			c = User.where(id: self.target_id)
			if c.count > 0 && c.first.gcm_devices.count > 0
				require 'gcm'
				gcm = GCM.new("AIzaSyDFOzJaBECT3D0L2ub0NX94T9h4ygkGyVY")

				e = ''
			  	d = 0
			  	if self.body.include? "followed"
				   e = 'User'
				   d = self.notifier_id
				elsif self.body.include? "Credit"
					e = 'Credit'
				elsif self.body.include? "liked your post"
					e = 'Post'
					d = self.body.split('***')[1].present? ? self.body.split('***')[1] : 0
				elsif self.body.include? "liked your review"
					e = 'Review'
					d = self.body.split('***')[1].present? ? self.body.split('***')[1] : 0
				elsif self.body.include? "liked your comment"
					e = 'Comment'
					d = self.body.split('***')[1].present? ? self.body.split('***')[1] : 0
				elsif self.body.include? "commented on"
					if self.body.include? "review"
						e = 'Review'
						d = self.body.split('***')[1].present? ? self.body.split('***')[1] : 0
					elsif self.body.include? "post"
						e = 'Post'
						d = self.body.split('***')[1].present? ? self.body.split('***')[1] : 0
					end
				end

				options = {data: {message: self.body.split('***')[0] , title: 'DishCuss' , redirect_id: d , redirect_type: e }, title_e: "DishCuss"}

				registration_ids= c.first.gcm_devices.where(device: 'android').pluck(:token) # an array of one or more client registration tokens
				if registration_ids.count > 0
					response = gcm.send(registration_ids, options)
				end

				apn = Houston::Client.development
			    apn.certificate = File.read("#{Rails.root}/config/requried.pem") # certificate from prerequisites
			   	apn.passphrase = "123456"
			   	@current_user.gcm_devices.where(device: 'ios').each do |tok|
			      notification = Houston::Notification.new(device: tok.token)
			      notification.alert = self.body.split('***')[0]
			      # take a look at the docs about these params
			      notification.badge = 1
			      notification.sound = "sosumi.aiff"
			      notification.custom_data = options
			      apn.push(notification)
			    end
			end
		end
	end
end
