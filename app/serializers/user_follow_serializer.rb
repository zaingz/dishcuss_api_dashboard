class UserFollowSerializer < ActiveModel::Serializer
  attributes :id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code

  def avatar
    if object.dp.present?
      k = object.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = object.avatar
    end
  	k
  end

end
