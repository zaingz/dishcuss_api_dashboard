class IdentityUserSerializer < ActiveModel::Serializer
  attributes :user_id , :email , :uid 

  def email
  	object.user ? object.user.email : ''
  end

  def user_id
  	object.user ? object.user.id : ''
  end
end
