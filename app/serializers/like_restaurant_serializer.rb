class LikeRestaurantSerializer < ActiveModel::Serializer
  attributes :id , :name , :location , :cover_image

  def id
  	id = ''
  	if object.likeable.present?
  		id = object.likeable.id
  	end
  	id
  end

  def name
  	name = ''
  	if object.likeable.present?
  		name = object.likeable.name
  	end
  	name
  end

  def location
  	location = ''
  	if object.likeable.present?
  		location = object.likeable.location
  	end
  	location
  end

  def cover_image
  	cover_image = ''
  	if object.likeable.present?
  		if object.likeable.cover_image.present?
  			if object.likeable.cover_image.image_url.present?
  				cover_image = object.likeable.cover_image.image_url.gsub('upload','upload/q_auto:low')
  			end
  		end
  	end
  	cover_image
  end
end
