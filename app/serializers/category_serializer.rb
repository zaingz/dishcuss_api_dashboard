class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name
  has_many :food_items
end
