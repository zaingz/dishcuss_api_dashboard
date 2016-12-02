class RestaurantExploreSerializer < ActiveModel::Serializer
  #root :restaurant
  attributes :id , :name, :typee , :location , :latitude , :longitude , :opening ,:closing , :rating , :price_per_head , :like  , :follow  , :menu , :checkins , :reviews
  has_one :cover_image
  #has_one :menu
  #has_many :checkins
  has_many :call_nows
  #has_many :reviews
  has_many :photos

  def checkins
    c = []
  end

  def reviews
    c = []
  end

  def opening
    object.opening_time.strftime("%I:%M %P")
  end

  def closing
    object.closing_time.strftime("%I:%M %P")
  end
  
  def like
  	object.likers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])

  end

  def follow
  	object.followers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
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
      #ch = MenuSerializer.new(object.menu , {root: false})
    end
    ch
  end

  def price_per_head
    object.per_head
  end

  def follows
    fo = false
    if serialization_options[:option_name].present?
      fo = serialization_options[:option_name].follows?(object)
    end
    fo
  end

  def likes
    fo = false
    if serialization_options[:option_name].present?
      fo = serialization_options[:option_name].likes?(object)
    end
    fo
  end
end
