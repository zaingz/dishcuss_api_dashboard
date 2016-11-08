class ReviewUserSerializer < ActiveModel::Serializer
  attributes :id , :updated_at , :title, :summary, :rating , :reviewable_id , :reviewable_type , :review_on , :review_likes , :bookmark , :image , :reviewer ,:likes , :shares
  has_many :comments
  has_many :reports

  def review_likes
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
    if User.where(id: object.reviewer_id).count > 0
     c = User.find(object.reviewer_id)
      if c.dp.present?
        k = c.dp.url.gsub('upload','upload/g_face,c_thumb,w_150,h_150')
      else
        k = c.avatar
      end
  	 rev = c.as_json(only: [:id , :name , :username , :email , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
     rev = rev.merge(avatar: k)
    end
    rev
  end

  def likes
  	object.likers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  end

  def bookmark
  	fo = false
    if scope[:option_name].present?
      if object.reviewable_type == 'Restaurant'
        if object.reviewable.present?
          fo = scope[:option_name].likes?(object.reviewable)
        end
      end
    end
    fo
  end
end
