class CheckinSerializer < ActiveModel::Serializer
  attributes :id, :address , :lat , :long , :time , :user ,  :restaurant , :restaurant_image

  def user
    c = object.post.user
    if c.dp.present?
      k = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = c.avatar
    end
  	g = c.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
    g = g.merge(avatar: k)
  end

  def time
  	object.created_at
  end

  def restaurant
  	object.restaurant.as_json(only: [:id, :name , :location ])
  end

  def restaurant_image
    sp = ""
    if object.restaurant.present?
      if object.restaurant.cover_image.present?
        if object.restaurant.cover_image.image_url.present?
          sp = object.restaurant.cover_image.image_url.gsub('upload','upload/q_auto:low')
        end
      end
    end
    sp
  end

end