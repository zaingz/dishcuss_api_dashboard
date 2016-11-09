class UserTokenSerializer < ActiveModel::Serializer
  #root :user
  attributes :id , :name, :username, :email, :avatar ,  :gender , :location , :date_of_birth , :email_verified ,:provider , :token , :referral_code , :referal_code_used

  def referal_code_used
    t = true
    if ( object.user.created_at > (Time.now - 5.minute) ) && ( object.user.referal_code_used == false )
      t = false
    end
    t
  end
  def email_verified
    object.user.verified
  end

  def avatar
    if object.user.dp.present?
      k = object.user.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = object.user.avatar
    end
  end

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
