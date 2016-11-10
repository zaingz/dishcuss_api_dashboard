class FoodItemSerializer < ActiveModel::Serializer
  attributes :id , :name, :price , :likes , :category , :photos
  #has_many :photos

  def likes
  	object.likers(User).as_json(only: [:id , :name , :username , :email , :avatar , :location , :gender , :dob , :role , :followees_count , :followers_count , :likees_count , :referal_code])
  end

  def category
  	object.categories.as_json(except: [:created_at, :updated_at])
  end

  def restaurant
  	object.section.menu.restaurant
  end

  def photos
    c = []
    object.photos.each do |rep|
      c.push(PhotoSerializer.new(rep , root: "photos"))
    end
    c
  end
end
