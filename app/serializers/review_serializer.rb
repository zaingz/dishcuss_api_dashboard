class ReviewSerializer < ActiveModel::Serializer
  attributes :id , :updated_at , :title, :summary, :rating , :reviewable_id , :reviewable_type , :review_on , :image , :reviewer ,:likes , :shares
  has_many :comments #, serializer: CommentSerializer, include: true
  has_many :reports


  def is_liked
    fo = false
    if scope[:option_name].present?
      fo = scope[:option_name].likes?(object)
    end
    fo
  end

  def review_on
    re = {}
    if object.reviewable.present?
  	 re = object.reviewable.as_json(except: [:created_at, :updated_at])
    end
    re
  end

  def image
    img = ""
    if object.reviewable.present?
      if object.reviewable_type == 'Restaurant'
        if object.reviewable.cover_image.present?
          if object.reviewable.cover_image.image_url.present?
            img = object.reviewable.cover_image.image_url.gsub('upload','upload/q_auto:low')
          end
        end
      end
    end
    img
  end

  def reviewer
    rev = {}
    c = User.where(id: object.reviewer_id)
    if c.count > 0
      l = c.first
     if l.dp.present?
      k = l.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
     else
      k = l.avatar
     end
  	 rev = l.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
     rev = rev.merge(avatar: k)
    end
    rev
  end

  def likes
  	object.likers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  end
end
