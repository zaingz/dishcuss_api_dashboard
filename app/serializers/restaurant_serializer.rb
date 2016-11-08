class RestaurantSerializer < ActiveModel::Serializer
  attributes :id, :name, :typee , :location , :latitude , :longitude , :opening ,:closing , :rating , :price_per_head , :owner ,:followers_count , :likers_count , :menu 
  has_one :cover_image
  #has_one :menu
  has_many :call_nows
  has_many :checkins


  def opening
  	object.opening_time.strftime("%I:%M %P")
  end

  def closing
  	object.closing_time.strftime("%I:%M %P")
  end

  def owner
  	object.owner.as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob])
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

  def menu
    ch = {}
    if object.menu.present?
      #ch = ActiveModel::Serializer.serializer_for()
      ch = MenuSerializer.new(object.menu , {root: false})
    end
    ch
  end

  def price_per_head
    object.per_head
  end

end
