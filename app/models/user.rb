class User < ActiveRecord::Base
	#validates_uniqueness_of :username
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable,
         :omniauthable, :omniauth_providers => [:facebook , :google_oauth2 , :twitter]

	validates_presence_of :email
	mount_uploader :dp , ImageUploader
	enum gender: [:male , :female]
	enum role: [:end_user , :restaurant_owner , :admin , :food_pundit]
	has_many :identities ,dependent: :destroy
	has_one :restaurant
	has_many :reviews, :as => 'reviewable' ,dependent: :destroy
	has_many :posts ,dependent: :destroy
	has_many :reports ,dependent: :destroy
	#has_many :messages
	has_one :review ,:as => 'reviewer' ,dependent: :destroy
	has_one :notification , :as => 'notifier' ,dependent: :destroy
	accepts_nested_attributes_for :identities
	#has_secure_password

	acts_as_follower
  	acts_as_followable
  	acts_as_liker

  	has_many :notifications , :as => 'target' ,dependent: :destroy
  	has_many :dislikes , :as => 'disliker' ,dependent: :destroy

  	has_one :referral, :as => 'referred' ,dependent: :destroy
  	has_many :referrals ,dependent: :destroy

  	has_one :credit ,dependent: :destroy

  	has_many :credit_histories ,dependent: :destroy

  	has_one :newsfeed , :as => 'feed' ,dependent: :destroy

  	has_many :gcm_devices ,dependent: :destroy

  	has_many :comments ,dependent: :destroy

  	def generate_referral_code
  		if self.username.present?
  			as = self.username
  		elsif self.name.present?
  			as = self.name
  		else
  			as = 'User'
  		end
		begin
	      self.referal_code = as + "_" + Random.rand(0..9999).to_s
	    end while self.class.exists?(referal_code: referal_code)
	end

	def referal_notification
		if self.referal_code_used == false
			if c = CreditAdjustment.find_by_typee('Referal')
				cre = self.credit
				pos = cre.points + c.points
				cre.update(points: pos)
				self.update(referal_code_used: true)
				Notification.create(target_id: self.id , target_type: 'User' , body: 'Credit is added to your account through referal')
			end
		end
	end

	def referal_sender_notification
		if c = CreditAdjustment.find_by_typee('Referal')
			cre = self.credit
			pos = cre.points + c.points
			cre.update(points: pos)
			self.update(referal_code_used: true)
			Notification.create(target_id: self.id , target_type: 'User' , body: 'Credit is added to your account through referal')
		end
	end

	def generate_email_verification_code
		begin
	      self.email_verification_code =  Random.rand(0..99999).to_s
	    end while self.class.exists?(referal_code: email_verification_code)
	end
end
