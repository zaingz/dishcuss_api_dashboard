class FoodItemsController < ApplicationController
	before_filter :restrict_access
	before_filter :is_restaurant_owner , except: [:add_image]

	def create
		if menu = Restaurant.where(owner_id: @owner.id).find(params[:food_item][:restaurant_id]).menu
			cat_foo = false
			food_item = FoodItem.new food_item_params
			food_item.menu_id = menu.id
			if food_item.save
				if params[:food_item][:category_id].present?
					cat_foo = true
					if params[:food_item][:category_id].count > 1
						params[:food_item][:category_id].each do |a|
							if cat = Category.find(a)
								food_item.categories << cat
							end
						end
					else
						food_item.categories << Category.find(params[:food_item][:category_id].first)
					end		
				end
				if params[:food_item][:category].present?
					cat_foo = true
					params[:food_item][:category].each do |a|
						if Category.where(name: a[:name]).count > 0
							category = Category.where(name: a[:name]).first
						else
							category = Category.create(:name => a[:name])
						end
						food_item.categories << category
					end
				end
				if cat_foo == false
					if Category.where(name: 'Uncategorized').count > 0
						 cate_uncat = Category.find_by_name('Uncategorized')
					else
						cate_uncat = Category.create(name: 'Uncategorized')
					end
					food_item.categories << cate_uncat
				end
				if params[:food_item][:image].present?
					params[:food_item][:image].each do |a|
		            	photo = Photo.create(:image => a, :imageable_id => food_item.id , :imageable_type => 'FoodItem')
		          	end
		        end
				render json: food_item, status: :created
			else
				render json: {'message' => 'Unprocessable entity'}, status: :unprocessable_entity
			end
		else
			render json: {'message' => 'Restaurant menu missing'}, status: :unprocessable_entity
		end
	end

	def update
		if food = FoodItem.find(params[:id])
			food.update(food_item_update_params)
			if params[:food_item][:category].present?
				params[:food_item][:category].each do |a|
					if Category.where(name: a[:name]).count > 0
						category = Category.where(name: a[:name]).first
					else
						category = Category.create(:name => a[:name])
					end
					food.categories << category
				end
			end
			if params[:food_item][:category_id].present?
				params[:food_item][:category_id].each do |a|
					food.categories.delete(a[:id])
					newCat = Category.create(:name => a[:name])
					food.categories << newCat
				end	
			end
			if params[:food_item][:image].present?
				if params[:food_item][:photo_id].present? && params[:food_item][:image].count==1
					p = food.photos.find(params[:food_item][:photo_id])
					
					p.update image: params[:food_item][:image].first
				else
					params[:food_item][:image].each do |a|
	            		photo = Photo.create(:image => a, :imageable_id => food.id , :imageable_type => 'FoodItem')
	          		end
	          	end
			end
			render json: {'message' => 'Successfully Updated!'}, status: :ok
		end
	end

	#def show
	#	if food = FoodItem.find(params[:id])
	#		render json: food, status: :ok
	#	end
	#end

	def destroy
		if food = FoodItem.find(params[:id])
			food.destroy
			head :no_content
		end
	end

	def add_image
		c = Restaurant.find(params[:id])
		ph = Photo.create(:image => params[:image], :imageable_id => params[:f_id] , :imageable_type => 'FoodItem')
		render json: {'message' => 'Successfully added'} , status: :ok
	end

	#def likeable
	#	@food_item = FoodItem.find(params[:id])
	#	@food_item.likers(User).each do |user|
	#		render json: ("first_name: " + user.first_name + ", last_name: " + user.last_name) , status: :ok
	#	end
	#end



	private
	def food_item_params
		params.require(:food_item).permit(:restaurant_id , :name , :price , :image , category: [:name] )
	end

	def food_item_update_params
		params.require(:food_item).permit(:name , :price ,:photo_id , :image , category: [:name] , category_id: [:id , :name] )
	end

	def join_params
		params.require(:food_category).permit(:category_id,:food_item_id)
	end
end
