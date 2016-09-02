class ReviewSerializer < ActiveModel::Serializer
  attributes :id , :updated_at , :title, :summary, :rating , :reviewable_id , :reviewable_type , :review_on , :image , :reviewer ,:likes
  has_many :comments
  has_many :reports

  def review_on
  	object.reviewable.as_json(except: [:created_at, :updated_at])
  end

  def image
    img = ""
    if object.reviewable_type == 'Restaurant'
      if object.reviewable.cover_image.present?
        img = object.reviewable.cover_image.image.url
      end
    end
    img
  end

  def reviewer
  	User.find(object.reviewer_id).as_json(except: [:created_at, :updated_at , :password])
  end

  def likes
  	object.likers(User).as_json(except: [:created_at, :updated_at , :password])
  end
end
