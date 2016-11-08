class UserSocialSerializer < ActiveModel::Serializer
  #root :user
  attributes :id , :name, :username, :email, :avatar , :location , :gender , :date_of_birth , :role , :following ,:followers , :likes , :reviews , :posts
  #has_many :posts
  #has_many :reviews

  def avatar
    if object.dp.present?
      k = object.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
    else
      k = object.avatar
    end
  end

  def date_of_birth
    object.dob.present? ? object.dob.strftime("%d-%m-%Y") : ""
  end

  def following
    c = []
    #:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code
  	object.followees(User).each do |usr|
      c.push(UserFollowSerializer.new(usr , {root: false}))
    end
    c
  end

  def followers
    c = []
  	object.followers(User).each do |usr|
      c.push(UserFollowSerializer.new(usr , {root: false}))
    end
    c   
  end

  def likes
  	object.likees_count
  end

  def reviews
    c = []
    Review.where(reviewer_id: object.id).order(updated_at: 'DESC').each do |rev|
      c.push(ReviewSerializer.new(rev , {root: false}))
    end
    c
  end

  def posts
    c = []
    object.posts.order(updated_at: 'DESC').each do |rev|
      c.push(PostSerializer.new(rev , {root: false}))
    end
    c
  end
end
