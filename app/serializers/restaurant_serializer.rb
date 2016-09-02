class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :location , :latitude , :longitude , :opening ,:closing , :rating , :owner ,:followers_count , :likers_count
  has_one :cover_image
  has_one :menu
  has_many :call_nows
  has_many :checkins


  def opening
  	object.opening_time.strftime("%I:%M %P")
  end

  def closing
  	object.closing_time.strftime("%I:%M %P")
  end

  def owner
  	object.owner.as_json(except: [:created_at, :updated_at , :password])
  end

  def rating
    count = 0
    ra = 0
    object.ratings.each do |rat|
      unless rat.rate.nil?
        ra = ra + rat.rate
        count = count + 1
      end
    end
    if ra != 0 && count != 0
        (ra.to_f()/count).round(1)
    else
      count
    end
  end

end
