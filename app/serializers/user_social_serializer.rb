class UserSocialSerializer < ActiveModel::Serializer
  attributes :id , :name, :username, :email, :avatar , :location , :gender , :date_of_birth , :role , :following ,:followers , :likes
  has_many :posts
  has_many :reviews
  has_many :messages , serializer: MessageWithRestaurantSerializer

  def date_of_birth
    object.dob.present? ? object.dob.strftime("%d-%m-%Y") : ""
  end

  def following
  	object.followees(User).as_json(except: [:created_at, :updated_at , :password])
  end

  def followers
  	object.followers(User).as_json(except: [:created_at, :updated_at , :password])
  end

  def likes
  	object.likees_count
  end
end
