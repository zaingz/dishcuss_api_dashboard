class CategorySerializer < ActiveModel::Serializer
  attributes :id, :name , :food_items
  #has_many :food_items

  def food_items
  	c = []
    object.food_items.each do |rep|
      c.push(FoodItemSerializer.new(rep , root: "food_items"))
    end
    c
  end
end
