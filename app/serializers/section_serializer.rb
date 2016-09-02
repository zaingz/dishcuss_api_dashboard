class SectionSerializer < ActiveModel::Serializer
  attributes :title
  has_many :food_items
end
