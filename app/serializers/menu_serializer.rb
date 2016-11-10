class MenuSerializer < ActiveModel::Serializer
  attributes :id, :name, :summary , :sections
  #has_many :sections

  def sections
  	c = []
    object.sections.each do |rep|
      c.push(SectionSerializer.new(rep , root: "sections"))
    end
    c
  end

end
