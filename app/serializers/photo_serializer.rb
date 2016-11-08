class PhotoSerializer < ActiveModel::Serializer
  attributes :id , :image_url
  has_many :reports

  def image_url
  	as = ""
  	if object.image_url.present?
  		as = object.image_url.gsub('upload','upload/q_auto:low')
  	end
  	as
  end
end
