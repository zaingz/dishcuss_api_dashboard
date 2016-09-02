class MessageWithRestaurantSerializer < ActiveModel::Serializer
  attributes :id, :body , :status  , :restaurant


  def restaurant
  	Restaurant.find(object.restaurant_id)
  end
end
