class QrcodeSerializer < ActiveModel::Serializer
  attributes :id , :code , :points , :description , :img
  has_one :offer_image
  has_one :restaurant
end
