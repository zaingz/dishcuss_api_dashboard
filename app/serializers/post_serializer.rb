class PostSerializer < ActiveModel::Serializer
  attributes :id, :updated_at , :title, :status , :writer , :likes
  has_one :checkin
  has_many :comments
  has_many :photos

  def writer
  	object.user.as_json(except: [:created_at, :updated_at , :password])
  end

  def likes
  	object.likers(User)
  end
end
