class CommentSerializer < ActiveModel::Serializer
  attributes :id ,:title ,:comment ,:commentor , :created_at , :likes
  has_many :reports

  def commentor
  	User.find(object.user_id).as_json(except: [:created_at, :updated_at , :password])
  end

  def likes
  	object.likers(User)
  end

end
