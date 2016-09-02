class MessageWithUserSerializer < ActiveModel::Serializer
  attributes :id , :body , :status , :user

  def user
  	User.find(object.user_id).as_json(except: [:created_at, :updated_at , :password])
  end

end
