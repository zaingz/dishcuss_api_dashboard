class User < ActiveRecord::Base
	#validates_uniqueness_of :username
	#validates_presence_of :username
	devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
	
	enum gender: [:male , :female]
	enum role: [:end_user , :restaurant_owner , :admin , :food_pundit]
	has_many :identities ,dependent: :destroy
	has_one :restaurant
	has_many :reviews, :as => 'reviewable'
	has_many :posts
	has_many :reports
	has_many :messages , :as => 'sender'
	has_many :messages , :as => 'reciever'
	has_one :review ,:as => 'reviewer'
	has_one :notification , :as => 'notifier'
	accepts_nested_attributes_for :identities
	#has_secure_password

	acts_as_follower
  	acts_as_followable
  	acts_as_liker

  	has_many :notifications , :as => 'target'
  	has_many :dislikes , :as => 'disliker'

  	has_one :referral, :as => 'referred'
  	has_many :referrals

  	has_one :credit

  	has_many :credit_histories

  	has_one :newsfeed , :as => 'feed'

  	def generate_referral_code
  		p self.username
		begin
	      self.referal_code = self.username + "_" + SecureRandom.hex.to_s
	    end while self.class.exists?(referal_code: referal_code)
	end
end
