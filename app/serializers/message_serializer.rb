class MessageSerializer < ActiveModel::Serializer
  attributes :id, :body , :status , :user , :restaurant

  def user
  	c = User.find(object.user_id)
  	if c.dp.present?
      k = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = c.avatar
    end
  	d = c.as_json(only: [:id , :name , :username , :email, :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  	d = d.merge(avatar: k)
  end

  def restaurant
  	Restaurant.find(object.restaurant_id)
  end
end