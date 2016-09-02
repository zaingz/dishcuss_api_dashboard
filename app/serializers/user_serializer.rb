class UserSerializer < ActiveModel::Serializer
  attributes :id , :name, :username, :email, :gender , :location , :date_of_birth, :referral_code 

  def date_of_birth
    object.dob.present? ? object.dob.strftime("%d-%m-%Y") : ""
  end

  def referral_code
    object.referal_code
  end
  
end
