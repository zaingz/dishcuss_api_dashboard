class CategoriesController < ApplicationController
	#before_filter :restrict_access
	#before_filter :is_restaurant_owner , only: [:create]
	def create
		category = Category.new category_params
		if category.save
			render json: category , status: :created
		else
			render json: {'message' => 'Unprocessable entity'}, status: :unprocessable_entity
		end
	end

	def index
		category = Category.all
		render json: category , status: :ok
	end

	def search
		if params[:name].present?
			arr = []
			cat = Category.find_by_name(params[:name])
			cat.food_items.each do |foodie|
				tempi = foodie.section.menu.restaurant
				unless arr.include?(tempi)
					arr << tempi
				end
			end
			render json: arr , each_serializer: RestaurantSocialSerializer , root: "restaurant"  , status: :ok
		else
			render json: {'message' => 'Category name missing !'} , status: :unprocessable_entity
		end
	end

	private
	def category_params
		params.require(:category).permit(:name)
	end
end
