class PhotoSerializer < ActiveModel::Serializer
  attributes :id , :image_url
  has_many :reports
end
