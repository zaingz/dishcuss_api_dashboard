class ReportSerializer < ActiveModel::Serializer
  attributes :id , :reason , :reporter

  def reporter
  	c = User.find(object.user.id)
  	if c.dp.present?
      k = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = c.avatar
    end
  	d = c.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  	d = d.merge(avatar: k)
  end
end