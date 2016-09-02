class UserMailer < ApplicationMailer
	default from: 'noreply@wifiexplore.com'

	def welcome_email(user)
		@url = "localhost:3000"
		@user = user
		mail(to: @user.email, subject: 'Dishcuss', body: 'Welcome. Please click on link to confirm email: ' + @url + '/user/email/verify/' + @user.identities.find_by_provider('Dishcuss').token )
	end

end