class PhotoSerializer < ActiveModel::Serializer
  attributes :id , :image_url , :reports
  #has_many :reports

  def image_url
  	as = ""
  	if object.image_url.present?
  		as = object.image_url.gsub('upload','upload/q_auto:low')
  	end
  	as
  end

  def reports
  	c = []
    object.reports.each do |rep|
      c.push(ReportSerializer.new(rep , root: "reports"))
    end
    c
  end

end
