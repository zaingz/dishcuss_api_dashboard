class RestaurantAllSerializer < ActiveModel::Serializer
  attributes :id , :name , :lat , :long

  def lat
    object.latitude
  end

  def long
  	object.longitude
  end
end
