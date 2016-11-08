class UserMailer < ApplicationMailer
	default from: 'hello@dishcuss.pk'

	def welcome_email(user)
		url = "localhost:3000"
		user = user
		mail(to: user.email, subject: 'DishCuss', body: 'Welcome. Please use that code in app: ' + user.email_verification_code )
	end

end