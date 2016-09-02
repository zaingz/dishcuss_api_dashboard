class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body , :status , :user , :restaurant

  def user
  	User.find(object.user_id).as_json(except: [:created_at, :updated_at , :password])
  end

  def restaurant
  	Restaurant.find(object.restaurant_id)
  end
end