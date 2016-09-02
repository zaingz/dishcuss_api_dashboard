class UserTokenSerializer < ActiveModel::Serializer
  root :user
  attributes :id , :name, :username, :email, :gender , :location , :date_of_birth ,:provider , :token , :referral_code

  def date_of_birth
    object.user.dob.present? ? object.user.dob.strftime("%d-%m-%Y") : ""
  end

  def location
    object.user.location
  end

  def id
  	object.user.id
  end
  def name
  	object.user.name
  end
  def username
  	object.user.username
  end
  def email
  	object.user.email
  end
  def gender
  	object.user.gender
  end
  def referral_code
    object.user.referal_code
  end
end
