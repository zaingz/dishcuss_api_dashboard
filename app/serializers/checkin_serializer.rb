class CheckinSerializer < ActiveModel::Serializer
  attributes :id, :address , :lat , :long , :time , :user ,  :restaurant , :restaurant_image

  def user
  	object.post.user.as_json(except: [:created_at, :updated_at , :password])
  end

  def time
  	object.created_at
  end

  def restaurant
  	object.restaurant.as_json(only: [:id, :name , :location ])
  end

  def restaurant_image
    if object.restaurant.cover_image.present?
      object.restaurant.cover_image.image.url
    end
  end

end
