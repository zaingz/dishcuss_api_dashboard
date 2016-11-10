class CommentSerializer < ActiveModel::Serializer
  attributes :id ,:title ,:comment ,:commentor , :created_at , :likes , :replies , :reports
  #has_many :reports
  #has_many :comments , root: 'replies'

  def commentor
  	d = {}
  	if c = User.find(object.user_id)
	  	if c.dp.present?
	      k = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
	    else
	      k = c.avatar
	    end
	  	d = c.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  		d = d.merge(avatar: k)
  	end
  	d
  end

  def likes
  	object.likers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  end

  def replies
    c = []
    object.comments.each do |rep|
      c.push(CommentSerializer.new(rep , root: "replies"))
    end
    c
  end

  def reports
    c = []
    object.reports.each do |rep|
      c.push(ReportSerializer.new(rep , root: "reports"))
    end
    c
  end

end
