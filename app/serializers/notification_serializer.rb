class NotificationSerializer < ActiveModel::Serializer
  attributes :id , :body , :notifier, :redirect_to , :seen 

  def body
  	object.body.split('***')[0]
  end

  def notifier
	if object.notifier_id.present?
		c = User.find(object.notifier_id)
		if c.dp.present?
	      f = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
	    else
	      f = c.avatar
	    end
  		k = c.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count])
		k = k.merge(avatar: f)
	elsif object.target_type == 'User'
		c = User.find(object.target_id)
		if c.dp.present?
	      f = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
	    else
	      f = c.avatar
	    end
		k = c.as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count])
		k = k.merge(avatar: f)
	end
  end

  def redirect_to
  	c = ''
  	d = 0
  	if object.body.include? "followed"
	   c = 'User'
	   d = object.notifier_id
	elsif object.body.include? "Credit"
		c = 'Credit'
	elsif object.body.include? "liked your post"
		c = 'Post'
		d = object.body.split('***')[1].present? ? object.body.split('***')[1] : 0
	elsif object.body.include? "liked your review"
		c = 'Review'
		d = object.body.split('***')[1].present? ? object.body.split('***')[1] : 0
	elsif object.body.include? "liked your comment"
		c = 'Comment'
		d = object.body.split('***')[1].present? ? object.body.split('***')[1] : 0
	elsif object.body.include? "commented on"
		if object.body.include? "review"
			c = 'Review'
			d = object.body.split('***')[1].present? ? object.body.split('***')[1] : 0
		elsif object.body.include? "post"
			c = 'Post'
			d = object.body.split('***')[1].present? ? object.body.split('***')[1] : 0
		end
	end
	d = {id: d , typee: c}
  end

end