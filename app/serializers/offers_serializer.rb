class OffersSerializer < ActiveModel::Serializer
  attributes :id , :points , :description , :qrcode_image , :restaurant , :offer_image

  def restaurant
  	unless object.restaurant_id.nil?
  		Restaurant.find(object.restaurant_id).as_json(only: [:id , :name, :opening_time , :closing_time , :location])
  	end
  end

  def qrcode_image
  	if object.img.present?
  		cc = object.img.split('/public')[1]
  		sa = 'http://dishcuss-api.herokuapp.com' + cc
    else
      ""
  	end
  end

  def offer_image
    if object.offer_image.present?
      if object.offer_image.image_url.present?
        object.offer_image.image_url
      else
        ""
      end
    else
      ""
    end
  end
end