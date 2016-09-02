class KhabaHistorySerializer < ActiveModel::Serializer
  attributes :id , :price , :credit_time , :offer_image , :restaurant 

  def credit_time
  	object.created_at
  end

  def restaurant
  	unless object.restaurant_id.nil?
  		Restaurant.find(object.restaurant_id).as_json(only: [:id , :name, :opening_time , :closing_time , :location])
  	end
  end

  def offer_image
    if object.qrcode_id.present?
  	 qr = Qrcode.find(object.qrcode_id)
     if qr.offer_image.present?
      qr.offer_image.image_url
     else
      ""
     end
    else
      ""
    end
  end
end
